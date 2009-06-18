require 'i18n'
require 'i18n/translation_properties'
require 'core_ext/object/deep_clone'
require 'core_ext/hash/iterate_nested'
require 'core_ext/hash/sorted_yaml_style'

module I18n
  class KeyExists < ArgumentError
    attr_reader :locale, :key
    def initialize(locale, key)
      @key, @locale = key, locale
      super "key exists: (#{locale}) :#{key.join('.')}"
    end
  end
  
  module Backend
    class SimpleStorage < Simple
      @@sort_keys = true
      
      class << self
        def sort_keys
          @@sort_keys
        end
        
        def sort_keys=(sort_keys)
          @@sort_keys = sort_keys
        end
      end
      
      def store_translations(locale, data)
        data.each_nested { |key, value| raise KeyExists.new(locale, key) if lookup(locale, key) }
        super
      end
    
      def copy_translations(from, to)
        init_translations unless initialized?
        I18n.available_locales.each do |locale|
          store_translations(locale, to => I18n.t(from, :raise => true))
        end
      end

      def remove_translation(key)
        init_translations unless initialized?
        key = I18n.send(:normalize_translation_keys, nil, key, nil)
        keys = available_locales.map { |locale| [locale] + key }
        translations.delete_nested_if { |k, v| keys.include?(k) } 
      end
      
      def save_translations(filenames = I18n.load_path.flatten)
        Array(filenames).each do |filename|
          save_file(filename, by_filename(filename))
        end
      end
    
      protected

        def load_yml(filename)
          YAML::load(IO.read(filename)).tap do |data| 
            set_translation_properties(data, :filename => filename) if data
          end
        end

        def by_filename(filename)
          select_translations { |keys, translation| translation.filename == filename }
        end

        def select_translations(&block)
          init_translations unless initialized?
          translations.select_nested(&block)
        end
      
        def each_translation(&block)
          init_translations unless initialized?
          translations.each_nested { |keys, t| block.call(keys.first, keys[1..-1], t) }
        end

        def save_file(filename, data)
          type = File.extname(filename).tr('.', '').downcase
          raise UnknownFileType.new(type, filename) unless respond_to?(:"save_#{type}")
          send(:"save_#{type}", filename, data)
        end

        def save_yml(filename, data)
          data = unset_translation_properties(data.deep_clone)
          data = deep_stringify_keys(data)
          File.open(filename, 'w+') do |f| 
            data.set_yaml_style(:sorted) if self.class.sort_keys
            f.write(data.to_yaml)
          end
        end

        def set_translation_properties(data, properties)
          data.each_nested do |key, value|
            value.meta_class.send(:include, TranslationProperties) unless value.respond_to?(:property_names)
            value.set_properties(properties)
          end and data
        end

        def unset_translation_properties(data)
          data.each_nested { |keys, value| value.unset_properties }
        end
      
        # Return a new hash with all keys and nested keys converted to strings.
        def deep_stringify_keys(hash)
          hash.inject({}) { |result, (key, value)|
            value = deep_stringify_keys(value) if value.is_a?(Hash)
            result[key.to_s] = value
            result
          }
        end
      end
  end
end