require 'spec_helper'

module DataGenerator
  describe Fake do
    let(:start_date) { Date.new(2015, 7, 1) }
    let(:end_date) { Date.new(2015, 7, 31) }
    let(:human_probability_pct) { 50 }
    let(:modules) { double('Array', sample: 'NEWS') }

    subject do
      Fake.new(start_date, end_date, human_probability_pct, modules)
    end

    describe '#timestamp' do
      let(:selected_time) { Time.new(2015, 7, 14, 12, 15, 15, 0) }

      before do
        day_start = start_date.beginning_of_day
        day_end = end_date.end_of_day
        Faker::Time.should_receive(:between).with(day_start, day_end, :all).and_return(selected_time)
      end

      its(:timestamp) { should == selected_time }
    end

    describe '#search_query' do
      before do
        Faker::Lorem.should_receive(:words).with(4).and_return(%w[the quick brown fox])
      end

      its(:search_query) { should == 'the quick brown fox' }
    end

    describe '#url' do
      before do
        Faker::Internet.should_receive(:url).and_return('http://example.com')
      end

      its(:url) { should == 'http://example.com' }
    end

    describe '#is_human?' do
      before do
        random = double('Random', rand: random_100)
        Random.should_receive(:new).and_return(random)
      end

      context 'when randomly-picked integer is below the threshold' do
        let(:random_100) { 30 }
        its(:is_human?) { should be_true }
      end

      context 'when randomly-picked integer is not below the threshold' do
        let(:random_100) { 80 }
        its(:is_human?) { should be_false }
      end
    end

    describe '#modules' do
      its(:modules) { should == ['NEWS'] }
    end
  end
end