describe AppDelegate do

  extend Facon::SpecHelpers

  before do
    @application = UIApplication.sharedApplication
    @delegate = @application.delegate
    @user = @delegate.instance_variable_get('@user')
  end

  describe "#application:didFinishLaunchingWithOptions:" do

    it "has one window" do
      @application.windows.first.should.be.instance_of(UIWindow)
    end

    it "makes the window key" do
      @application.windows.first.isKeyWindow.should.be.true
    end

    it "sets the root view controller to the navigation controller" do
      @application.windows.first.rootViewController.should.be.instance_of(UINavigationController)
    end

    describe "users" do

      context "when a user doesn't exist" do

        it "creates a new user" do
          @user.should.not == nil
        end
      end

      context "when a user does exist" do

        before do
          @existing_user = User.new
          @existing_user.save
        end

        it "loads the existing user" do
          @user.id.should == @existing_user.id
        end
      end
    end
  end

end
