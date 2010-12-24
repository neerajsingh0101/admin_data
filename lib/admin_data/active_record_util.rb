module AdminData
  class ActiveRecordUtil

    attr_accessor :klass

    def initialize(klass)
      @klass = klass
    end

    # class User
    #   has_and_belongs_to_many :clubs
    # end
    #
    # ActiveRecordUtil.new(User).declared_habtm_association_names
    # #=> ['clubs']
    def declared_habtm_association_names
      delcared_association_names_for(:has_and_belongs_to_many).map(&:name).map(&:to_s)
    end

    # class User
    #   belongs_to :club
    # end
    #
    # ActiveRecordUtil.new(User).declared_belongs_to_association_names
    # #=> ['club']
    def declared_belongs_to_association_names
      delcared_association_names_for(:belongs_to).map(&:name).map(&:to_s)
    end

    # class User
    #   has_one :car
    # end
    #
    # ActiveRecordUtil.new(User).declared_has_one_association_names
    # #=> ['car']
    def declared_has_one_association_names
      delcared_association_names_for(:has_one).map(&:name).map(&:to_s)
    end

    # class User
    #   has_many :cars
    # end
    #
    # ActiveRecordUtil.new(User).declared_has_many_association_names
    # #=> ['cars']
    def declared_has_many_association_names
      delcared_association_names_for(:has_many).map(&:name).map(&:to_s)
    end

    # returns an array of classes
    #
    # class User
    #   has_and_belongs_to_many :clubs
    # end
    #
    # ActiveRecordUtil.new(User).habtm_klasses_for
    # #=> [Club]
    def habtm_klasses_for
      declared_habtm_association_names.map do |assoc_name|
        klass_for_association_type_and_name(:has_and_belongs_to_many, assoc_name)
      end
    end

    # returns a class or nil
    #
    # class User
    #   has_many :comments
    # end
    #
    # ActiveRecordUtil.new(User).klass_for_association_type_and_name(:has_many, 'comments')
    # #=> Comment
    #
    def klass_for_association_type_and_name(association_type, association_name)
      data = klass.name.camelize.constantize.reflections.values.detect do |value|
        value.macro == association_type && value.name.to_s == association_name
      end
      data.klass if data # output of detect from hash is an array with key and value
    end

    # returns false if the given Klass has no association info. Otherwise returns true.
    def has_association_info?
      declared_belongs_to_association_names.any? ||
      declared_has_many_association_names.any? ||
      declared_has_many_association_names.any? ||
      declared_habtm_association_names.any?
    end

    private

    # returns declared association names like
    #
    # #=> ['comments']
    # #=> ['positive_comments']
    # #=> ['negative_comments']
    def delcared_association_names_for(association_type)
      klass.name.camelize.constantize.reflections.values.select do |value|
        value.macro == association_type
      end
    end

  end
end
