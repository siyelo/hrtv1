

o = Organization.find_by_name('MOH')
p = Project.find_by_name 'Quality and demand for services in the control of diseases-current expenditures in SCPS covered'

p = Project.find(:all, :conditions => ['name LIKE ? ', '%'+'SCPS'+'%'])
p = Project.find(:all, :conditions => ['description LIKE ? ', '%'+'SCPS'+'%'])
p = Activity.find(:all, :conditions => ['name LIKE ? ', '%'+'SCPS'+'%'])

ot = Organization.find(:all, :conditions => ['name LIKE ? ', '%'+'CTAMS'+'%'])


# find the source org (MOH)

# find the target org

# check if the target org has a Data Response already

# if no DR, create one

# clone the project

# set the project to point to new target

# [remove the original project]