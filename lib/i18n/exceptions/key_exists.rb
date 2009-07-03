module I18n
  class KeyExists < ArgumentError
    attr_reader :locale, :key
    def initialize(locale, key)
      @key, @locale = key, locale
      super "key exists: (#{locale}) :#{key.join('.')}"
    end
  end
end