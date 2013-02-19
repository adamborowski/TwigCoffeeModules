TwigCoffeeModules
=================

The solution for keeping right execution order of disordered loaded coffeescripts via {% javascripts %} Assetic block

coffee file must start with:

module 'name_of_module'

require 'module1 module2 moduleN'

define ->

  # all required definitions are stored in window.module so You can use it as:
  
  module.some_required_module_name.some_definition
  
  
