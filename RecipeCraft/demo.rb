require_relative "./app"

egg   = Ingredient.new("яйце", :pcs, 72.0)         
milk  = Ingredient.new("молоко", :ml, 0.06)        
flour = Ingredient.new("борошно", :g, 3.64)        
pasta = Ingredient.new("паста", :g, 3.5)           
sauce = Ingredient.new("соус", :ml, 0.2)           
cheese= Ingredient.new("сир", :g, 4.0)            

pantry = Pantry.new
pantry.add("борошно", 1, :kg)
pantry.add("молоко", 0.5, :l)  
pantry.add("яйце", 6, :pcs)     
pantry.add("паста", 300, :g)    
pantry.add("сир", 150, :g)      

price_list = {
  "борошно" => 0.02,
  "молоко"  => 0.015,
  "яйце"    => 6.0,
  "паста"   => 0.03,
  "соус"    => 0.025,
  "сир"     => 0.08
}

omelet = Recipe.new("Омлет")
omelet.add_ingredient(egg, 3, :pcs)
omelet.add_ingredient(milk, 100, :ml)
omelet.add_ingredient(flour, 20, :g)

pasta_recipe = Recipe.new("Паста")
pasta_recipe.add_ingredient(pasta, 200, :g)
pasta_recipe.add_ingredient(sauce, 150, :ml)
pasta_recipe.add_ingredient(cheese, 50, :g)

recipes = [omelet, pasta_recipe]

result = Planner.plan(recipes, pantry, price_list)