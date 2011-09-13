# Its necessary to turn off Timecop after a scenario has been executed
After do
  Timecop.return
end