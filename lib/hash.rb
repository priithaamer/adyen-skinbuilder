# Taken from File activesupport/lib/active_support/core_ext/hash/keys.rb, line 23
#  + added symbolize_keys! for values

class Hash
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = if (value = delete(key)) && value.is_a?(Hash)
        value.symbolize_keys!
      else
        value
      end
    end
    self
  end
end
