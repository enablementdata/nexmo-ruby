require 'minitest/autorun'
require 'nexmo'
require 'json'

describe 'Nexmo::Entity' do
  let(:entity) { Nexmo::Entity.new }

  it 'maps keyword args to attribute names' do
    value = 'xxxx-xxxx'

    entity = Nexmo::Entity.new(id: value)
    entity.id.must_equal(value)
  end

  it 'maps string keys to attribute names' do
    value = '2015-03-21 11:50:56'

    entity['date_submitted'] = value
    entity.date_submitted.must_equal(value)
  end

  it 'maps hyphenated string keys to underscored attribute names' do
    value = 'DELIVRD'

    entity['final-status'] = value
    entity.final_status.must_equal(value)
  end

  it 'maps camelcase string keys to underscored attribute names' do
    value = 'United Kingdom'

    entity['countryDisplayName'] = value
    entity.country_display_name.must_equal(value)
  end

  it 'works with json object_class' do
    entity = JSON.parse('{"value":100.00,"autoReload":false}', object_class: Nexmo::Entity)

    entity.must_be_instance_of(Nexmo::Entity)
    entity.value.must_equal(100)
    entity.auto_reload.must_equal(false)
  end

  it 'is equal to other entity objects with the same attributes' do
    entity1 = Nexmo::Entity.new(key: 'value')
    entity2 = Nexmo::Entity.new(key: 'value')

    entity1.object_id.wont_equal(entity2.object_id)
    entity1.must_equal(entity2)
  end

  it 'is not equal to other kinds of objects' do
    entity.wont_equal({})
  end

  describe 'to_h method' do
    it 'returns the attributes hash' do
      value = 'xxxx-xxxx'

      entity[:id] = value
      entity.to_h.must_equal({id: value})
    end
  end
end
