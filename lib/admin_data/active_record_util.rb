module AdminData
  class ActiveRecordUtil

    def self.declared_habtm_association_names(klass)
      delcared_association_names_for(klass, :has_and_belongs_to_many).map(&:name).map(&:to_s)
    end

    def self.declared_belongs_to_association_names(klass)
      delcared_association_names_for(klass, :belongs_to).map(&:name).map(&:to_s)
    end

    def self.declared_has_one_association_names(klass)
      delcared_association_names_for(klass, :has_one).map(&:name).map(&:to_s)
    end

    def self.declared_has_many_association_names(klass)
      delcared_association_names_for(klass, :has_many).map(&:name).map(&:to_s)
    end

    # returns declared association names like
    # #=> [comments]
    # #=> [positive_comments]
    # #=> [negative_comments]
    def self.delcared_association_names_for(klass, association_type)
      klass.name.camelize.constantize.reflections.values.select do |value|
        value.macro == association_type
      end
    end

    # returns an array of classes
    # #=> [Comment]
    def self.habtm_klasses_for(klass)
      declared_habtm_association_names(klass).map do |assoc_name|
        klass_for_association_type_and_name(klass, :has_and_belongs_to_many, assoc_name)
      end
    end

    # returns a class or nil
    #
    # class User
    #   has_many :comments
    # end
    #
    # AdminData::ActiveRecordUtil.habtm_klass_for_association_name(User, 'comments') #=> Comment
    def self.klass_for_association_type_and_name(klass, association_type, association_name)
      data = klass.name.camelize.constantize.reflections.values.detect do |value|
        value.macro == association_type && value.name.to_s == association_name
      end
      data.klass if data # output of detect from hash is an array with key and value
    end
    # TODO test with polymorphic


    def self.association_info_size(k)
      AdminData::ActiveRecordUtil.declared_belongs_to_association_names(k).any? ||
      AdminData::ActiveRecordUtil.declared_has_many_association_names(k).any? ||
      AdminData::ActiveRecordUtil.declared_has_many_association_names(k).any? ||
      AdminData::ActiveRecordUtil.declared_habtm_association_names(k).any?
    end

  end
end
