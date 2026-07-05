module MiniSupport
  class HashWithIndifferentAccess < Hash
    def []=(key, value)
      super(key.to_s, value)
    end

    def [](key)
      super(key.to_s)
    end

    # Hash#merge だと渡されたキーを変換せずにしようするため、result[k] = v の形で []= を使用させている
    def merge(other)
      result = self.class.new
      each { |k, v| result[k] = v }
      other.each { |k, v| result[k] = v }
      result
    end
  end
end
