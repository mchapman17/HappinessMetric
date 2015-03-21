class AppDelegate

  attr_accessor :user, :group

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = UIViewController.alloc.init
    rootViewController.title = 'Happiness Metric'
    rootViewController.view.backgroundColor = UIColor.blackColor

    @user = User.load || User.new(id: BubbleWrap.create_uuid, score: 2.5)
    @group = Group.load || Group.new(id: "68db153d-dbd4-43d2-bc61-85057562fd83", name: "Hooroo", score: 2.5)

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
