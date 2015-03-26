class GroupSettingsController < UIViewController

  def initWithGroup(group)
    self.initWithNibName(nil, bundle:nil)
    @group = group

    self.title = "Group Settings"
    self.view.backgroundColor = UIColor.whiteColor
    self
  end

  def viewDidLoad
    super

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight

    self.view.addSubview(@table)

    @table.dataSource = self

    @data = ["Name", "Password", "Min. Score", "Max. Score", "Interval", "Reset Scores"]
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "settings_row"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    cell.textLabel.text = @data[indexPath.row]

    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

end
