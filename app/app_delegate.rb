class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = UIViewController.alloc.init
    rootViewController.title = 'HappinessMetric'
    rootViewController.view.backgroundColor = UIColor.blackColor

    @happiness = Happiness.load || Happiness.new(user_score: 2.5, group_score: 0)
    @happiness.get_average_group_score
    puts "group: #{@happiness.group_score}"
    @happiness_controller = HappinessController.alloc.initWithHappiness(@happiness)

    @nav_controller = UINavigationController.alloc.initWithRootViewController(@happiness_controller)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @nav_controller
    @window.makeKeyAndVisible

    true
  end

  def applicationDidEnterBackground(application)
    puts "background: user_score: #{@happiness.user_score}"
    @happiness.save
  end

  def applicationWillTerminate(application)
    puts "terminate: user_score: #{@happiness.user_score}"
    @happiness.save
  end

end
