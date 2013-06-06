
module Mock
  class Stub
    attr_accessor :type_name, :attributes

    def initialize(name,is_array=false)
      @type_name = name
      @attributes = []
    end
  end

  class Attribute

    attr_reader :name, :type, :description

    # should be booleans
    attr_reader :array, :nullable, :readonly, :required

    def initialize(name, type, args={})

      args = {:is_array => false, :is_null => false, :is_readonly => false, :required => false, :description => ""}.merge(args)

      @name = name
      @type = type
      @description = args[:description]
      @array = args[:is_array]
      @nullable = args[:is_null]
      @readonly = args[:is_readonly]
      @description = args[:description]
      @required = args[:required]
    end

    def array?
      @array
    end

    def mockclass?
      @type.kind_of?(Mock::Stub)
    end

    def nullable?
      @nullable
    end

    def readonly?
      @readonly
    end

    def required?
      @required
    end

    private :array, :nullable, :readonly, :required
  end
end