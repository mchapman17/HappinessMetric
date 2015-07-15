class AppDelegate

  attr_accessor :user, :group, :score

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    rootViewController = UIViewController.alloc.init
    rootViewController.title = 'Happiness Metric'
    rootViewController.view.backgroundColor = UIColor.blackColor

    @user = User.load || User.new(id: BubbleWrap.create_uuid, score: 0.0)
    @group = Group.load || Group.default
    @score = Score.load || Score.default
puts "score ---------------- #{@score.inspect}"
    @application_controller = ApplicationController.alloc.initWithUser(@user, group: @group, score: @score)

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
