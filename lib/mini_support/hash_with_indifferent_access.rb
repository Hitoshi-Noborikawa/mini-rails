module MiniSupport
  class HashWithIndifferentAccess < Hash
    def []=(key, value)
      super(key.to_s, value)
    end

    def [](key)
      super(key.to_s)
    end

    # Hash#merge would keep the given keys as they are, so each pair goes through []= via result[k] = v
    def merge(other)
      result = self.class.new
      each { |k, v| result[k] = v }
      other.each { |k, v| result[k] = v }
      result
    end
  end
end
