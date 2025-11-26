module UnitConverter
  MASS = [:g, :kg]
  VOLUME = [:ml, :l]
  PIECES = [:pcs]

  def self.base_unit(unit)
    return :g  if MASS.include?(unit)
    return :ml if VOLUME.include?(unit)
    return :pcs if PIECES.include?(unit)
    raise ArgumentError, "Unknown unit #{unit}"
  end

  def self.to_base(qty, unit)
    case unit
    when :kg then [qty * 1000.0, :g]
    when :g  then [qty.to_f, :g]
    when :l  then [qty * 1000.0, :ml]
    when :ml then [qty.to_f, :ml]
    when :pcs then [qty.to_f, :pcs]
    else
      raise ArgumentError, "Не підтримується одиниця: #{unit}"
    end
  end

  def self.compatible_units?(unit_a, unit_b)
    base_unit(unit_a) == base_unit(unit_b)
  end
end


class Ingredient
  attr_reader :name, :base_unit, :calories_per_unit

  def initialize(name, unit, calories_per_unit)
    @name = name.to_s
    @base_unit = UnitConverter.base_unit(unit)
    @calories_per_unit = calories_per_unit.to_f
  end
end


class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps = [])
    @name = name
    @steps = steps
    @items = []
  end

  def add_ingredient(ingredient, qty, unit)
    base_of_unit = UnitConverter.base_unit(unit)
    if base_of_unit != ingredient.base_unit
      raise ArgumentError,
        "Одиниця #{unit} не підходить для '#{ingredient.name}'. Маса ↔ об'єм заборонено."
    end

    @items << { ingredient: ingredient, qty: qty.to_f, unit: unit }
  end

  def need
    result = Hash.new { |h, k| h[k] = { qty: 0.0, unit: nil, ingredient: nil } }

    @items.each do |it|
      ing = it[:ingredient]
      qty_base, base_unit = UnitConverter.to_base(it[:qty], it[:unit])

      entry = result[ing.name]
      entry[:qty] += qty_base
      entry[:unit] = base_unit
      entry[:ingredient] = ing
    end

    result
  end
end


class Pantry
  def initialize
    @store = {}
  end

  def add(name, qty, unit)
    qty_base, base_unit = UnitConverter.to_base(qty, unit)

    if @store.key?(name.to_s)
      if @store[name.to_s][:unit] != base_unit
        raise ArgumentError, "Несумісні одиниці для '#{name}' у коморі"
      end
      @store[name.to_s][:qty] += qty_base
    else
      @store[name.to_s] = { qty: qty_base, unit: base_unit }
    end
  end

  def available_for(name)
    entry = @store[name.to_s]
    return [0.0, nil] unless entry
    [entry[:qty], entry[:unit]]
  end
end


class Planner
  def self.plan(recipes, pantry, price_list)
    total_need = Hash.new { |h, k| h[k] = { qty: 0.0, unit: nil, ingredient: nil } }

    recipes.each do |r|
      r.need.each do |name, info|
        total_need[name][:qty] += info[:qty]
        total_need[name][:unit] = info[:unit]
        total_need[name][:ingredient] = info[:ingredient]
      end
    end

    total_calories = 0.0
    total_cost = 0.0

    puts "План для рецептів: #{recipes.map(&:name).join(', ')}"
    puts "-" * 50

    total_need.each do |name, info|
      need_qty = info[:qty]
      unit = info[:unit] || :pcs
      have_qty, have_unit = pantry.available_for(name)
      have_unit ||= unit

      if have_unit != unit
        raise "Несумісні одиниці для '#{name}' (#{unit} vs #{have_unit})"
      end

      deficit = [need_qty - have_qty, 0.0].max

      ing = info[:ingredient]
      total_calories += need_qty * ing.calories_per_unit if ing

      price = price_list[name.to_s]
      total_cost += need_qty * price if price

      puts "Інгредієнт: #{name}"
      puts "  потрібно: #{need_qty.round(2)} #{unit}"
      puts "  є:        #{have_qty.round(2)} #{unit}"
      puts "  дефіцит:  #{deficit.round(2)} #{unit}"
      puts
    end

    puts "-" * 50
    puts "Сумарна калорійність: #{total_calories.round(2)} ккал"
    puts "Сумарна вартість:     #{total_cost.round(2)}"

    {
      items: total_need.transform_values { |v|
        have_qty, _ = pantry.available_for(v[:ingredient].name)
        {
          need: v[:qty],
          have: have_qty,
          deficit: [v[:qty] - have_qty, 0.0].max,
          unit: v[:unit]
        }
      },
      total_calories: total_calories,
      total_cost: total_cost
    }
  end
end
