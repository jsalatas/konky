require 'cairo'

elements = {
    {
        kind = 'bar_graph',
        conky_value = 'fs_used_perc /',
        from = {x = 4, y = 60},
        to = {x = 303, y = 60},
        background_thickness = 20,
        bar_thickness = 16,
     },
    {
        kind = 'bar_graph',
        conky_value = 'fs_used_perc /home',
        from = {x = 4, y = 104},
        to = {x = 303, y = 104},
        background_thickness = 20,
        bar_thickness = 16,
     },
}



function hexa_to_rgb(color, alpha)
    -- ugh, whish this wans't an oneliner
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end


function get_conky_value(conky_value, is_number)
    -- evaluate a conky template to get its current value
    -- example: "cpu cpu0" --> 20

    local value = conky_parse(string.format('${%s}', conky_value))

    if is_number then
        value = tonumber(value)
    end
    if value==nil then
      return 0
    end
    return value
end


function draw_line(display, element)
    -- draw a line

    -- deltas for x and y (cairo expects a point and deltas for both axis)
    local x_side = element.to.x - element.from.x -- not abs! because they are deltas
    local y_side = element.to.y - element.from.y -- and the same here
    local from_x =element.from.x
    local from_y = element.from.y

    if not element.graduated then
      -- draw line
      cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
      cairo_set_line_width(display, element.thickness);
      cairo_move_to(display, element.from.x, element.from.y);
      cairo_rel_line_to(display, x_side, y_side);
    else
      -- draw graduated line
      cairo_set_source_rgba(display, hexa_to_rgb(element.color, element.alpha))
      cairo_set_line_width(display, element.thickness);
      local space_graduation_x = (x_side-x_side/element.space_between_graduation+1)/element.number_graduation
      local space_graduation_y =(y_side-y_side/element.space_between_graduation+1)/element.number_graduation
      local space_x = x_side/element.number_graduation-space_graduation_x
      local space_y = y_side/element.number_graduation-space_graduation_y

      for i=1,element.number_graduation do
          cairo_move_to(display,from_x,from_y)
          from_x=from_x+space_x+space_graduation_x
          from_y=from_y+space_y+space_graduation_y
          cairo_rel_line_to(display,space_x,space_y)
      end
    end
    cairo_stroke(display)
end


function draw_bar_graph(display, element)
    -- draw a bar graph
    -- Used a little bit of trigonometry to be able to draw bars in any direction! :)

    -- get current value

    value = get_conky_value(element.conky_value, true)
    if value > element.max_value   then
        value = element.max_value
    end

    -- dimensions of the full graph
    local x_side = element.to.x - element.from.x
    local y_side = element.to.y - element.from.y
    local hypotenuse = math.sqrt(math.pow(x_side, 2) + math.pow(y_side, 2))
    local angle = math.atan2(y_side, x_side)

    -- dimensions of the value bar
    local bar_hypotenuse = value * (hypotenuse / element.max_value)
    local bar_x_side = bar_hypotenuse * math.cos(angle)
    local bar_y_side = bar_hypotenuse * math.sin(angle)

    -- is it in critical value?
    local color_critical_or_not_suffix = ''
    local alpha_critical_or_not_suffix = ''
    local thickness_critical_or_not_suffix = ''
    if value >= element.critical_threshold then
        if element.change_color_on_critical then
            color_critical_or_not_suffix = '_critical'
        end
        if element.change_alpha_on_critical then
            alpha_critical_or_not_suffix = '_critical'
        end
        if element.change_thickness_on_critical then
            thickness_critical_or_not_suffix = '_critical'
        end
    end

    -- background line (full graph)
    background_line = {
        from = element.from,
        to = element.to,

        color = element['background_color' .. color_critical_or_not_suffix],
        alpha = element['background_alpha' .. alpha_critical_or_not_suffix],
        thickness = element['background_thickness' .. thickness_critical_or_not_suffix],
        graduated = element.graduated,
        number_graduation=element.number_graduation,
        space_between_graduation=element.space_between_graduation,
    }
    bar_line = {
        from = element.from,
        to = {x=element.from.x + bar_x_side, y=element.from.y + bar_y_side},

        color = element['bar_color' .. color_critical_or_not_suffix],
        alpha = element['bar_alpha' .. alpha_critical_or_not_suffix],
        thickness = element['bar_thickness' .. thickness_critical_or_not_suffix],
    }
    -- draw background lines
    draw_line(display, background_line)

  if element.graduated then
      -- draw bar line if graduated
      cairo_set_source_rgba(display, hexa_to_rgb(bar_line.color, bar_line.alpha))
      cairo_set_line_width(display, bar_line.thickness);
      local from_x = bar_line.from.x
      local from_y = bar_line.from.y
      local space_graduation_x = (x_side-x_side/element.space_between_graduation+1)/element.number_graduation
      local space_graduation_y =(y_side-y_side/element.space_between_graduation+1)/element.number_graduation
      local space_x = x_side/element.number_graduation-space_graduation_x
      local space_y = y_side/element.number_graduation-space_graduation_y

      for i=1,bar_x_side/(space_x+space_graduation_x) do

          cairo_move_to(display,from_x,from_y)
          from_x=from_x+space_x+space_graduation_x
          from_y=from_y+space_y+space_graduation_y
          cairo_rel_line_to(display,space_x,space_y)
      end

    cairo_stroke(display)
  else
    -- draw bar line if not graduated
    draw_line(display,bar_line);
  end

end


-- properties that the user *must* define, because they don't have default
-- values
requirements = {
    line = {'from', 'to'},
    bar_graph = {'from', 'to', 'conky_value'},
}


-- Default values for properties that can have a default value
defaults = {
    bar_graph = {
        max_value = 100.,
        critical_threshold = 90.,

        background_color = 0x2363D9,
        background_alpha = 0.4,
        background_thickness = 1,

        bar_color = 0x41B1F7,
        bar_alpha = 0.7,
        bar_thickness = 1,

        background_color_critical = 0xF741B1,
        background_alpha_critical = 0.4,
        background_thickness_critical = 1,

        bar_color_critical = 0xD92363,
        bar_alpha_critical = 0.7,
        bar_thickness_critical = 1,

        change_color_on_critical = true,
        change_alpha_on_critical = false,
        change_thickness_on_critical = false,

        graduated = false,
        number_graduation=0,
        space_between_graduation=1,

        draw_function = draw_bar_graph,
    },
}


function check_requirements(elements)
    -- check every element has the required properties
    for i, element in pairs(elements) do
        -- find the requirements for that element kind
        kind_requirements = requirements[element.kind]
        -- if there are defined requirements for that element kind
        if  kind_requirements ~= nil then
            -- check all of them are defined by the user
            for i, property in pairs(kind_requirements) do
                if element[property] == nil then
                    error('You defined a ' .. element.kind .. ' without specifying its "' .. property .. '" value')
                end
            end
        else
            -- we don't know which properties has to have, BUT, it always needs
            -- a draw_function
            if element.draw_function == nil then
                error('You defined a ' .. element.kind .. ', which is unknown element kind to me. Was it a typo? or are you trying to define a custom element kind but forgot to define its draw_function?')
            end
        end
    end
end


function fill_defaults(elements)
    -- fill each each element with the missing values, using the defaults
    for i, element in pairs(elements) do
        -- find the defaults for that element kind
        kind_defaults = defaults[element.kind]
        -- only if there are defined defaults for that element kind
        if  kind_defaults ~= nil then
            -- fill the element with the defaults (for the properties without
            -- value)
            for key, value in pairs(kind_defaults) do
                if element[key] == nil then
                    element[key] = kind_defaults[key]
                end
            end
        end
    end
end


function conky_main()
    if conky_window == nil then
        return
    end

    check_requirements(elements)
    fill_defaults(elements)

    local surface = cairo_xlib_surface_create(conky_window.display,
                                              conky_window.drawable,
                                              conky_window.visual,
                                              conky_window.width,
                                              conky_window.height)
    local display = cairo_create(surface)

    if tonumber(conky_parse('${updates}')) > 3 then
        for i, element in pairs(elements) do
            element.draw_function(display, element)
        end
    end

    cairo_surface_destroy(surface)
end
