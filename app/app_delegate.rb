class AppDelegate

  attr_accessor :user, :group, :api_handler

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = UIViewController.alloc.init
    rootViewController.title = 'Happiness Metric'
    rootViewController.view.backgroundColor = UIColor.blackColor

    @user = User.load || User.new(id: BubbleWrap.create_uuid, score: 0.0)
    @group = Group.load || Group.default

    @api_handler = ApiHandler.alloc.init
    @api_handler.get_group_average_score

    @application_controller = ApplicationController.alloc.initWithUser(@user, group: @group, api_handler: @api_handler)

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
