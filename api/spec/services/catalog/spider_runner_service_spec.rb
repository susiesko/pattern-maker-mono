# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::SpiderRunnerService do
  describe '#call' do
    let(:service) { described_class.new('miyuki', max_pages: 10) }

    before do
      allow(service).to receive(:require_spider) # Stub the require to avoid loading the actual spider
      allow(MiyukiSpider).to receive(:run).and_return(true)
    end

    it 'runs the specified spider' do
      result = service.call

      expect(MiyukiSpider).to have_received(:run).with(hash_including(max_pages: 10))
      expect(result).to include(success: true)
    end

    context 'when an error occurs' do
      before do
        allow(MiyukiSpider).to receive(:run).and_raise(StandardError.new('Test error'))
      end

      it 'returns an error result' do
        result = service.call

        expect(result).to include(success: false)
        expect(result[:message]).to include('Test error')
      end
    end
  end
end