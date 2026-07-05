# frozen_string_literal: true

module MiniPack
  class Flash
    def initialize(session)
      @session = session
      @current = session.delete('_flash') || {} # 前回リクエストの flash
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

    # render 時に使う。現リクエスト内だけで有効で、次のリクエストには渡らない。
    def now
      @current
    end

    # レスポンスを返す前に呼び出す。次のリクエスト用の flash を session に保存する
    def persist!
      @next.any? ? @session['_flash'] = @next : @session.delete('_flash')
    end
  end
end
