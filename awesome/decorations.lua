local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local drawing = require("util.drawing")

local M = {}

local max_height = 0
local max_width = 0

local add_decorations
local add_top_bar
local set_shape
local add_borders
local get_top_background_widget
local get_side_border_widget
local make_title_widget
local make_left_buttons
local make_one_button
local update_max_screen_dims

local theme

-- TODO
local hack_empty_widget = {
    widget = wibox.widget.textbox
}

-- TODO need this?
update_max_screen_dims = function()
    local height, width = 0, 0

    for s in screen do
        height = math.max(height, s.geometry.height)
        width = math.max(width, s.geometry.width)
    end

    max_height = height * 1.5
    max_width = width * 1.5
end

set_shape = function(c)

    -- TODO Disabling shaping for now.
    -- It messes with either the shadows or antialiasing,
    -- hard to make both look good.
    -- Disabling shadows for now, so the shape doesn't matter much.
    -- Downside is that you can grab to drag OUTSIDE of the rounded corners,
    -- but that doesn't seem like a big deal.

    c.shape = gears.shape.rectangle
    do
        return
    end

    if c.fullscreen then
        c.shape = gears.shape.rectangle
    else
        local shape_br = theme.radius_bottom
        local shape_tr = theme.radius_top - 2
        if shape_tr < 0 then
            shape_tr = 0
        end

        c.shape = drawing.rounded_rect {
            tl = shape_tr,
            tr = shape_tr,
            bl = shape_br,
            br = shape_br
        }
    end
end

add_decorations = function(c)
    set_shape(c)
    add_top_bar(c)
    add_borders(c)
end

make_title_widget = function(c)
    local widget = wibox.widget {
        widget = wibox.widget.textbox,
        text = c.name, -- TODO bold, font, color
        align = "center"
    }

    c:connect_signal("property::name", function(c)
        widget.text = c.name
    end)

    return widget
end

make_one_button = function(args)
    local c = args.client
    local radius = args.radius
    local base_color = args.base_color
    local hover_color = args.hover_color
    local inactive_color = args.inactive_color

    local callback = args.callback

    local surf = nil
    local cur_state = nil

    local surf_normal = drawing.circle {
        radius = radius,
        base_color = base_color
    }

    local surf_hover = drawing.circle {
        radius = radius,
        base_color = hover_color
    }

    local surf_inactive = drawing.circle {
        radius = radius,
        base_color = inactive_color,
    }

    local widget = wibox.widget {
        widget = wibox.widget.imagebox,
        resize = false,
    }

    local function update_surf(state)
        local color, stroke

        if state == cur_state then return end
        cur_state = state
        
        if state == "normal"
        then
            surf = surf_normal
        elseif state == "hover"
        then
            surf = surf_hover
        elseif state == "inactive"
        then
            surf = surf_inactive
        end

        widget.image = surf
    end

    local initial_state
    if client.focus == c then initial_state = "normal"
    else initial_state = "inactive"
    end
    update_surf(initial_state)

    -- TODO can't for the life of me get hovering
    -- to work just over the button
    widget:connect_signal("mouse::enter", function()
        update_surf("hover")
    end)

    widget:connect_signal("mouse::leave", function()
        local foc = (client.focus == c)
        if foc then update_surf("normal")
        else update_surf("inactive")
        end
    end)

    client.connect_signal("focus", function()
        local foc = (client.focus == c)
        if foc then update_surf("normal")
        else update_surf("inactive")
        end
    end)

    widget:connect_signal("button::release", function(_, _, _, btn)
        if btn ~= 1 then return end
        callback()
    end)

    return widget
end

make_left_buttons = function(c, radius)
    local close_cb = function()
        c:kill()
    end

    local close = make_one_button {
        client = c,
        radius = radius,
        base_color = "#ff605c",
        hover_color = "#ff7b6d",
        inactive_color = "#dedede",
        callback = close_cb
    }

    return close
end

add_top_bar = function(c)
    local base_color = theme.base_color
    local outer_color = theme.outer_color
    local inner_color = theme.inner_color

    local bar = awful.titlebar(c, {
        size = theme.titlebar_height,
        position = "top",
        bg = "transparent"
    })

    local left_corner_surf = drawing.rounded_corner_top_left {
        radius = theme.radius_top,
        height = theme.titlebar_height,
        extra_width = 30,
        outer_stroke_width = theme.outer_stroke_width,
        inner_stroke_width = theme.inner_stroke_width,
        base_color = base_color,
        outer_color = outer_color,
        inner_color = inner_color
    }

    local right_corner_surf = drawing.flip_h(left_corner_surf)

    -- TODO don't need to use join?
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.move(c)
    end))

    local title_text_widget = make_title_widget(c)

    local top_bg = get_top_background_widget {
        outer_width = theme.outer_stroke_width,
        inner_width = theme.inner_stroke_width,
        outer_color = theme.outer_color,
        inner_color = theme.inner_color,
        base_color = theme.base_color
    }

    local left_buttons = make_left_buttons(c, 9)

    bar:setup{
        layout = wibox.layout.align.horizontal,

        -- TODO can't drag the window from the left corner
        -- Left
        {
            widget = wibox.container.background,
            bgimage = left_corner_surf,
            forced_width = left_corner_surf:get_width(),

            {
                widget = wibox.container.place,

                left_buttons
            }
        },

        -- Middle
        {
            layout = wibox.layout.stack,
            buttons = buttons,

            top_bg,
            title_text_widget
        },

        -- Right
        {
            widget = wibox.widget.imagebox,
            image = right_corner_surf,
            resize = false,
            buttons = buttons
        }
    }
end

get_top_background_widget = function(args)
    local outer_width = args.outer_width
    local inner_width = args.inner_width

    local outer_color = args.outer_color
    local inner_color = args.inner_color
    local base_color = args.base_color

    return {
        layout = wibox.layout.fixed.vertical,
        fill_space = true,

        {
            widget = wibox.widget.background,
            bg = outer_color,
            forced_height = outer_width,

            hack_empty_widget
        },

        {
            widget = wibox.widget.background,
            bg = inner_color,
            forced_height = inner_width,

            hack_empty_widget
        },

        {
            widget = wibox.widget.background,
            bg = base_color,

            hack_empty_widget
        }
    }
end

get_side_border_widget = function(args)
    local color_one = args.color_one
    local color_two = args.color_two
    local width_one = args.width_one
    local width_two = args.width_two

    local orientation = args.orientation
    local outer_layout
    local inner_layout
    if orientation == "v" then
        outer_layout = wibox.layout.flex.vertical
        inner_layout = wibox.layout.ratio.horizontal
    else
        outer_layout = wibox.layout.flex.horizontal
        inner_layout = wibox.layout.ratio.vertical
    end

    local inner_widget = wibox.widget {
        layout = inner_layout,

        {
            widget = wibox.widget.background,
            bg = color_one,

            hack_empty_widget
        },

        {
            widget = wibox.widget.background,
            bg = color_two,

            hack_empty_widget
        }
    }

    local ratio = width_one / (width_one + width_two)
    inner_widget:set_ratio(1, ratio)
    inner_widget:set_ratio(2, 1 - ratio)

    return {
        layout = outer_layout,
        inner_widget
    }
end

add_borders = function(c)
    local thickness = theme.outer_stroke_width + theme.inner_stroke_width
    local outer_color = theme.outer_color
    local inner_color = theme.inner_color

    local left = awful.titlebar(c, {
        size = thickness,
        position = "left"
    })

    local right = awful.titlebar(c, {
        size = thickness,
        position = "right"
    })

    local bottom = awful.titlebar(c, {
        size = thickness,
        position = "bottom"
    })

    local left_bar_contents = get_side_border_widget {
        orientation = "v",
        color_one = outer_color,
        color_two = inner_color,
        width_one = theme.outer_stroke_width,
        width_two = theme.inner_stroke_width
    }

    local right_bar_contents = get_side_border_widget {
        orientation = "v",
        color_one = inner_color,
        color_two = outer_color,
        width_one = theme.inner_stroke_width,
        width_two = theme.outer_stroke_width
    }

    local bottom_bar_center = get_side_border_widget {
        orientation = "h",
        color_one = inner_color,
        color_two = outer_color,
        width_one = theme.inner_stroke_width,
        width_two = theme.outer_stroke_width
    }

    left:setup(left_bar_contents)
    right:setup(right_bar_contents)

    local bottom_left_surf = drawing.sharp_corner_bottom_left {
        outer_width = theme.outer_stroke_width,
        inner_width = theme.inner_stroke_width,
        outer_color = outer_color,
        inner_color = inner_color
    }

    local bottom_right_surf = drawing.flip_h(bottom_left_surf)

    bottom:setup{
        layout = wibox.layout.align.horizontal,

        {
            widget = wibox.widget.imagebox,
            image = bottom_left_surf,
            resize = false
        },

        bottom_bar_center,

        {
            widget = wibox.widget.imagebox,
            image = bottom_right_surf,
            resize = false
        }
    }
end

M.initialize = function()
    theme = beautiful._decorations

    update_max_screen_dims()

    -- Add a titlebar if titlebars_enabled is set to true in the rules
    client.connect_signal("request::titlebars", function(c)
        add_decorations(c)
    end)

    -- Make sure we don't use rounded corners in fullscreen
    client.connect_signal("property::fullscreen", function(c)
        set_shape(c)
    end)
end

return M
