# frozen_string_literal: true

module MiniPack
  class Flash
    def initialize(session)
      @session = session
      @current = session.delete('_flash') || {} # flash from the previous request
      @next = MiniSupport::HashWithIndifferentAccess.new
    end

    def [](key)
      @current[key.to_s]
    end

    def []=(key, value)
      @next[key.to_s] = value
    end

    def notice
      self[:notice]
    end

    def notice=(value)
      self[:notice] = value
    end

    def alert
      self[:alert]
    end

    def alert=(value)
      self[:alert] = value
    end

    # Used with render. Valid only in the current request and not carried to the next one.
    def now
      @current
    end

    # Called before returning the response. Saves the flash for the next request in the session
    def persist!
      @next.any? ? @session['_flash'] = @next : @session.delete('_flash')
    end
  end
end
