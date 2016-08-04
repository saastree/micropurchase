require_relative '../schema'

class Swagger::Schema::Object < Swagger::Schema
  def type
    'object'
  end

  def properties
    properties_hash.values
  end

  def property(key)
    properties_hash[key]
  end

  def compact_type
    name
    # if properties.length > 0 && properties.length < 3
    #   "<#{name+' ' unless name.nil?}{" + properties.map {|p| '"' + p.name + '": ' + p.compact_type}.join(', ') + '}>'
    # else
    #   "<#{name} object>"
    # end
  end

  def sample_value
    ''
  end

  private

  def properties_hash
    if @_properties.nil?
      @_properties = {}

      if fields.key?('properties')
        fields['properties'].each do |name, value|
          @_properties[name] = Swagger::Schema.factory(name, value, @specification)
        end
      end
    end

    @_properties
  end
end
