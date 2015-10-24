# A quick way to ensure that the FactoryGirl factories are valid.
#
# Changing model validations can cause lots of unit tests to fail. This spec
# helps catch those validation failures at the source, before running the
# entire test suite.
FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "The #{factory_name} factory" do
     it 'is valid' do
      expect(FactoryGirl.build(factory_name)).to be_valid
     end
  end
end
