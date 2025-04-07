# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::RunSpiderJob, type: :job do
  describe '#perform' do
    let(:spider_name) { 'miyuki' }
    let(:options) { { max_pages: 10 } }
    let(:service) { instance_double(Catalog::SpiderRunnerService) }

    before do
      allow(Catalog::SpiderRunnerService).to receive(:new).and_return(service)
    end

    context 'when the spider runs successfully' do
      before do
        allow(service).to receive(:call).and_return({ success: true, message: 'Success' })
      end

      it 'calls the spider runner service' do
        subject.perform(spider_name, options)

        expect(Catalog::SpiderRunnerService).to have_received(:new).with(spider_name, options)
        expect(service).to have_received(:call)
      end
    end

    context 'when the spider fails' do
      let(:error) { StandardError.new('Test error') }

      before do
        allow(service).to receive(:call).and_return({ success: false, message: 'Failed', error: error })
      end

      it 'raises the error' do
        expect { subject.perform(spider_name, options) }.to raise_error(StandardError, 'Test error')
      end
    end
  end
end