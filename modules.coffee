class Module
      constructor: (name) ->
            @_requirements = {}
            @name = name
      addRequiredModule: (module) ->
            @_requirements[module.name] = module;

      requiresModule: (module)->
            return @_requirements.hasOwnProperty module.name

      addBody: (def) ->
            @_body = def
      getDefinitions: ->
            @_definitions
      execute: ->
            #nie możemy przesyłać całych modułów, tylko ich definicje, jednak przed wywołaniem trzeba generować nowe dane, bo
            # zmieny mogą zachodzić
            requiredDefinitions={}
            for name of @_requirements
                  requiredDefinitions[name] = @_requirements[name].getDefinitions()
            window.module = requiredDefinitions
            @_definitions = @_body()


class Modules
# jeśli żądamy modułu, to należy zapewnić mu aktualne pierwsze miejsce w kolejce ładowania
      getModule: (name) ->
            if @isModuleCreated name
                  module = @_modules[name]
                  #console.log "queue > splice at #{@_executeQueue.indexOf module}"
                  #@_executeQueue.splice(@_executeQueue.indexOf(module), 1)
            else
                  module = new Module(name)
                  @_modules[module.name] = module
            return module
      setCurrentModule: (module)->
            #console.log "setting current module to #{module.name}"
            @_currentModule = module

            return
      addRequire: (libs)=>
            #console.log "adding requirements to #{@_currentModule.name} for #{libs}"
            libs = libs.split ' '
            for libName in libs
                  module=@getModule libName
                  @_currentModule.addRequiredModule module

      addBody: (body)=>
            @_currentModule.addBody body
            module=@_currentModule
            @_currentModule = null

            #teraz sprawdź kolejki
            #włóż do kolejki, przepychaj się na początek, lecz nie wyprzedzaj kolesia, którego wymaga

            @_executeQueue.push module
            q=@_executeQueue
            lastPosition=q.length - 1
            currentPos=lastPosition
            while currentPos > 0

                  #sprawdzaj miejsca od przedostatniego do zerowego, czy nie siedzi tam koleś którego wymagam
                  closerPos=currentPos - 1
                  if(module.requiresModule(q[closerPos]))
                        #nie przesiadaj się dalej
                        break
                  #przesiądź się o jedno miejsce
                  q[currentPos] = q[closerPos]
                  q[closerPos] = module
                  currentPos--

            return
      # trzeba czasem sprawdzić, czy moduł już nie został utworzony przez require
      isModuleCreated: (name)->
            return @_modules[name]?

      execute: ->
            # odwracamy, gdyż na końcu kolejki jest najpotrzebniejszy zasób
            module.execute() for module in @_executeQueue
            return
      _currentModule: null
      _executeQueue: []
      _modules:
            {}


modules = new Modules

window.module = (name)->
      if name?
            modules.setCurrentModule(modules.getModule(name))
      else
            modules.execute()
      return
window.require = modules.addRequire
window.define = modules.addBody
