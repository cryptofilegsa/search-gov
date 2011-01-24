require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::BoostedSitesController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for #new" do
        get :new, :affiliate_id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :new, :affiliate_id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who owns the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :new, :affiliate_id => affiliates(:power_affiliate).id
      end

      should_render_template 'affiliates/boosted_sites/new.html.haml', :layout => 'account'
    end
  end

  describe "create" do
    it "should require affiliate login" do
      post :create, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "logged in" do
      before :each do
        @affiliate = affiliates(:basic_affiliate)
        UserSession.create(@affiliate.owner)
      end

      it "should redirect back to new if a new site is added" do
        post :create, :affiliate_id => @affiliate.to_param, :boosted_site => {:url => "a url", :title => "a title", :description => "a description"}

        response.should redirect_to new_affiliate_boosted_site_path
        
        @affiliate.reload
        @affiliate.boosted_sites.length.should == 1
      end

      it "should render if errors" do
        post :create, :affiliate_id => @affiliate.to_param, :boosted_site => {:url => "a url", :description => "a description"}

        response.should render_template(:new)
        @affiliate.reload
        @affiliate.boosted_sites.length.should == 0

        assigns[:boosted_site].errors[:title].should == "can't be blank"
      end

      it "should ?? if adding a duplicate url"

    end
  end

  describe "update" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      @boosted_site = @affiliate.boosted_sites.create!(:url => "a url", :title => "a title", :description => "a description")
      UserSession.create(@affiliate.owner)
    end

    it "should redirect back to new on success" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_site.to_param, :boosted_site => {:url => "new url", :title => "new title", :description => "new description"}

      response.should redirect_to new_affiliate_boosted_site_path

      @boosted_site.reload
      @boosted_site.url.should == "new url"
      @boosted_site.title.should == "new title"
      @boosted_site.description.should == "new description"
    end

    it "should render if errors" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_site.to_param, :boosted_site => {:url => "new url", :title => "new title", :description => ""}

      response.should render_template(:edit)

      assigns[:boosted_site].errors[:description].should == "can't be blank"
    end


    it "should ?? if updating to a duplicate url"

  end

  describe "destroy" do
    it "should delete, flash, and redirect" do
      affiliate = affiliates(:basic_affiliate)
      boosted_site = affiliate.boosted_sites.create!(:url => "a url", :title => "a title", :description => "a description")
      UserSession.create(affiliate.owner)

      post :destroy, :affiliate_id => affiliate.to_param, :id => boosted_site.to_param

      response.should redirect_to new_affiliate_boosted_site_path
      affiliate.reload.boosted_sites.should be_empty
    end

  end

  describe "bulk upload" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      UserSession.create(@affiliate.owner)
      @xml = StringIO.new("xml")
    end

    it "should process the xml file and redirect to new" do
      BoostedSite.should_receive(:process_boosted_site_xml_upload_for).with(@affiliate, @xml).and_return(true)

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should redirect_to new_affiliate_boosted_site_path
    end

    it "should notify if errors" do
      BoostedSite.should_receive(:process_boosted_site_xml_upload_for).with(@affiliate, @xml).and_return(false)

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should render_template(:new)
      flash[:error].should =~ /could not be processed/
    end
  end
end
