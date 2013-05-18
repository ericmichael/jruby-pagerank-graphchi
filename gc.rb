#All needed GraphChi dependencies are loaded into the GC module
module GC
    include_package "edu.cmu.graphchi"
    include_package "edu.cmu.graphchi.preprocessing"
    include_package "edu.cmu.graphchi.datablocks"
    include_package "edu.cmu.graphchi.engine"
    include_package "edu.cmu.graphchi.util"
    
    # jRuby Floats bind to Java Doubles
    # GraphChi does not have a built in converter
    # to handle them so we build our own
    # TODO: Make this less hackish.
    # Using FloatConverter directly causes a typecast error
    # It is unclear why subclassing and calling the super function
    # fixes this typecast error.
    class DoubleConverter < FloatConverter
        def setValue(array, val)
            super
       end
    end
end
