select id,
(SELECT COUNT(*) FROM code_assignments WHERE code_assignments.activity_id = activities.id) AS code_assignments_count
FROM activities
ORDER BY code_assignments_count DESC
LIMIT 15

DELETE FROM activities
WHERE id NOT IN (2296, 2298, 1155, 2300, 2294, 2304, 2301, 2302, 2309, 2314, 2307, 2312, 2313, 2308, 2303)
