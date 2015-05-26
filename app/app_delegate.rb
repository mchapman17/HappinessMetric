class AppDelegate

  attr_accessor :user, :group, :api_handler

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = UIViewController.alloc.init
    rootViewController.title = 'Happiness Metric'
    rootViewController.view.backgroundColor = UIColor.blackColor

    @user = User.load || User.new(id: BubbleWrap.create_uuid, score: 0.0)
    @group = Group.load || Group.default

    @application_controller = ApplicationController.alloc.initWithUser(@user, group: @group)

    @nav_controller = UINavigationController.alloc.initWithRootViewController(@application_controller)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @nav_controller
    @window.makeKeyAndVisible

    true
  end

  def applicationDidEnterBackground(application)
    save
  end

  def applicationWillTerminate(application)
    save
  end

  def save
    @user.save
    @group.save
  end

end
