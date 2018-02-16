shared_examples_for 'a record with a fetchable url' do
  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to allow_value("http://some.site.gov/url").for(:url) }
    it { is_expected.to allow_value("http://some.site.mil/").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.com/url").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.us/url").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.info/url").for(:url) }
    it { is_expected.to allow_value("https://some.govsite.info/url").for(:url) }

    it 'limits the url length to 2000 characters' do
      record = described_class.new(valid_attributes.merge(url: ('x' * 2001) ))
      expect(record).not_to be_valid
      expect(record.errors[:url]).to include("is too long (maximum is 2000 characters)")
    end

    context 'when the url extension is blacklisted' do
      let(:movie_url) { "http://www.nps.gov/some.mov" }
      let(:record) { described_class.new(valid_attributes.merge(url: movie_url)) }

      it "is not valid" do
        expect(record).not_to be_valid
        expect(record.errors.full_messages.first).to match(/extension is not one we index/i)
      end
    end
  end

  describe "normalizing URLs when saving" do
    context "when a blank URL is passed in" do
      let(:url) { "" }
      it 'should mark record as invalid' do
        expect(described_class.new(valid_attributes.merge(url: url))).not_to be_valid
      end
    end

    context "when an URL contains an anchor tag" do
      let(:url) { "http://www.nps.gov/sdfsdf#anchorme" }
      it "should remove it" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/sdfsdf")
      end
    end

    context "when URL is mixed case" do
      let(:url) { "HTTP://Www.nps.GOV/UsaGovLovesToCapitalize" }
      it "should downcase the scheme and host only" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/UsaGovLovesToCapitalize")
      end
    end

    context "when URL is missing trailing slash for a scheme+host URL" do
      let(:url) { "http://www.nps.gov" }
      it "should append a /" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/")
      end
    end

    context "when URL contains duplicate leading slashes in request" do
      let(:url) { "http://www.nps.gov//hey/I/am/usagov/and/love/extra////slashes.shtml" }
      it "should collapse the slashes" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/hey/I/am/usagov/and/love/extra/slashes.shtml")
      end
    end
  end
end