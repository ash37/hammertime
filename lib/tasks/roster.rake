namespace :roster do
  desc "Generate draft timesheets from user roster templates for today"
  task generate_timesheets: :environment do
    TimesheetEntry.generate_drafts_for(Date.current)
  end
end
