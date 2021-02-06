local lgi = require("lgi")
local gears = require("gears")

local rad = math.rad
local cairo = lgi.cairo

local M = {}

M.rounded_rect = function(args)
    local r1 = args.tl or 0
    local r2 = args.bl or 0
    local r3 = args.br or 0
    local r4 = args.tr or 0

    return function(cr, width, height)
        width = width
        height = height
        cr:new_sub_path()
        cr:arc(width - r1, r1, r1, rad(-90), rad(0))
        cr:arc(width - r2, height - r2, r2, rad(0), rad(90))
        cr:arc(r3, height - r3, r3, rad(90), rad(180))
        cr:arc(r4, r4, r4, rad(180), rad(270))
        cr:close_path()
    end
end

M.flip_h = function(surface)
    local width = surface:get_width()
    local height = surface:get_height()

    local flipped = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(flipped)

    local source_pattern = cairo.Pattern.create_for_surface(surface)
    source_pattern.matrix = cairo.Matrix {
        xx = -1,
        yy = 1,
        x0 = width
    }
    -- source_pattern.matrix = cairo.Matrix {xx = 1, yy = -1, y0 = height}

    cr.source = source_pattern
    cr:rectangle(0, 0, width, height)
    cr:paint()

    return flipped
end

M.rounded_corner_top_left = function(args)
    local radius = args.radius
    local height = args.height
    local extra = args.extra_width or 0
    local total_width = radius + extra
    
    local outer_stroke_width = args.outer_stroke_width
    local inner_stroke_width = args.inner_stroke_width
    local base_color = args.base_color
    local outer_color = args.outer_color
    local inner_color = args.inner_color

    local surface = cairo.ImageSurface.create("ARGB32", total_width, height)
    local cr = cairo.Context.create(surface)
    cr.antialias = cairo.Antialias.BEST

    cr:move_to(0, height)
    cr:line_to(0, radius)
    cr:arc(radius, radius, radius, rad(180), rad(270))
    cr:line_to(total_width, 0)
    cr:line_to(total_width, height)
    cr:close_path()

    cr:set_source_rgba(gears.color.parse_color(base_color))
    cr:fill()

    local function do_stroke(offset, width, color)
        cr:move_to(offset, height)
        cr:line_to(offset, radius + offset)
        cr:arc(radius + offset, radius + offset, radius, rad(180), rad(270))
        cr:line_to(total_width, 0)
        cr:set_line_width(width)
        cr:set_source_rgba(gears.color.parse_color(color))
        cr:stroke()
    end

    local outer_offset = outer_stroke_width / 2
    local inner_offset = outer_stroke_width + (inner_stroke_width / 2)
    do_stroke(outer_offset, outer_stroke_width, outer_color)
    do_stroke(inner_offset, inner_stroke_width, inner_color)

    return surface
end

M.circle = function(args)
    local radius = args.radius
    local width = radius + radius

    local color = args.base_color

    local twopi = rad(360)

    local surface = cairo.ImageSurface.create("ARGB32", width, width)
    local cr = cairo.Context.create(surface)
    cr.antialias = cairo.Antialias.BEST

    cr:arc(radius, radius, radius, 0, twopi)
    cr:set_source_rgba(gears.color.parse_color(color))
    cr:fill()

    return surface
end

M.sharp_corner_bottom_left = function(args)
    local outer_width = args.outer_width
    local inner_width = args.inner_width
    local outer_color = args.outer_color
    local inner_color = args.inner_color
    
    local width = outer_width + inner_width

    local surface = cairo.ImageSurface.create("ARGB32", width, width)
    local cr = cairo.Context.create(surface)

    cr:set_source_rgba(gears.color.parse_color(outer_color))
    cr:rectangle(0, 0, width, width)
    cr:fill()

    cr:set_source_rgba(gears.color.parse_color(inner_color))
    cr:rectangle(outer_width, 0, inner_width, inner_width)
    cr:fill()

    return surface
end

return M