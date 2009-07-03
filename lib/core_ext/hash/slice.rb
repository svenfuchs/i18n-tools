# from activesupport

class Hash
  # Returns a new hash with only the given keys.
  def slice(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
  
  # Replaces the hash with only the given keys.
  # Returns a hash contained the removed key/value pairs
  #   {:a => 1, :b => 2, :c => 3, :d => 4}.slice!(:a, :b) # => {:c => 3, :d =>4}
  def slice!(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
  end
end