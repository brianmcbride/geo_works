require 'spec_helper'

describe GeoWorks::BoundingBoxHelper do
  let(:property) { :coverage }
  let(:helper) { TestingHelper.new }
  before do
    class TestingHelper
      include GeoWorks::BoundingBoxHelper

      def curation_concern
      end
    end
  end
  after do
    Object.send(:remove_const, :TestingHelper)
  end

  before do
    vector_work = instance_double('vector_work', class: VectorWork)
    allow(helper).to receive(:curation_concern).and_return(vector_work)
  end

  describe '#bbox' do
    it 'builds bounding box selector' do
      expect(helper.bbox(property)).to include("{inputId: vector_work_coverage})")
    end
  end

  describe '#bbox_display_inputs' do
    subject { helper.bbox_display_inputs }
    it { is_expected.to include('North', 'East', 'South', 'West') }
  end

  describe '#base_input_id' do
    it 'returns the id of the bounding box input element' do
      expect(helper.bbox_input_id(property)).to eq('vector_work_coverage')
    end
  end
end
