select *
from code_assignments
where ( amount = 0 and cached_amount != 0) or (amount !=0 and cached_amount = 0)
/* note that amount will usually be nil when percentage is not nil, so this doesn't pick up places where percentages are handled correctly */

select *
from code_assignments
where ( (amount = 0 or percentage = 0) and cached_amount != 0) or ((amount !=0 or percentage !=0) and cached_amount = 0)
/* general check for code assignment makes no sense / has bad cached amount */
