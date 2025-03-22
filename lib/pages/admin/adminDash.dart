import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNIVOTE Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Election {
  final String title;
  final String department;
  final DateTime startDate;
  final DateTime endDate;
  final int candidates;
  final bool isActive;

  Election({
    required this.title,
    required this.department,
    required this.startDate,
    required this.endDate,
    required this.candidates,
    required this.isActive,
  });
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Election> _elections = [
    Election(
      title: 'Class Representative',
      department: 'B22 CS',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2, hours: 5)),
      candidates: 5,
      isActive: true,
    ),
    Election(
      title: 'Department Secretary',
      department: 'CSE',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 5, hours: 12)),
      candidates: 3,
      isActive: true,
    ),
    Election(
      title: 'Student Council',
      department: 'General Secretary',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      candidates: 0,
      isActive: false,
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _candidatesController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _candidatesController.dispose();
    super.dispose();
  }

  void _createElection() {
    if (_titleController.text.isEmpty || _departmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final candidates = int.tryParse(_candidatesController.text) ?? 0;

    final newElection = Election(
      title: _titleController.text,
      department: _departmentController.text,
      startDate: _startDate,
      endDate: _endDate,
      candidates: candidates,
      isActive: _startDate.isBefore(DateTime.now()) && _endDate.isAfter(DateTime.now()),
    );

    setState(() {
      _elections.add(newElection);
      _titleController.clear();
      _departmentController.clear();
      _candidatesController.clear();
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Election created successfully')),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
      );

      if (time != null) {
        setState(() {
          if (isStartDate) {
            _startDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            );
            // Ensure end date is after start date
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(days: 1));
            }
          } else {
            _endDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            );
          }
        });
      }
    }
  }

  void _showCreateElectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Election'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Election Title*',
                  hintText: 'e.g., Class Representative',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department/Position*',
                  hintText: 'e.g., CSE, B22 CS',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _candidatesController,
                decoration: const InputDecoration(
                  labelText: 'Number of Candidates',
                  hintText: 'Enter 0 if registration is open',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date & Time'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(_startDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('End Date & Time'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(_endDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: _createElection,
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final activeElections = _elections.where((e) => 
      e.startDate.isBefore(now) && e.endDate.isAfter(now)).toList();
    final upcomingElections = _elections.where((e) => 
      e.startDate.isAfter(now)).toList();
    final pastElections = _elections.where((e) => 
      e.endDate.isBefore(now)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'UNIVOTE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Spacer(),
            CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white, 
              child: Text('AB'),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Elections',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${activeElections.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Expanded(
                //   child: Card(
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           const Text(
                //             'Upcoming Elections',
                //             style: TextStyle(
                //               fontSize: 18,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //           const SizedBox(height: 8),
                //           Text(
                //             '${upcomingElections.length}',
                //             style: const TextStyle(
                //               fontSize: 24,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.orange,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 16),
                // Expanded(
                //   child: Card(
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           const Text(
                //             'Total Elections',
                //             style: TextStyle(
                //               fontSize: 18,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //           const SizedBox(height: 8),
                //           Text(
                //             '${_elections.length}',
                //             style: const TextStyle(
                //               fontSize: 24,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.green,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Elections',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateElectionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Election'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Active Elections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            if (activeElections.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No active elections'),
                  ),
                ),
              )
            else
              ...activeElections.map((election) => _buildElectionCard(election)),
            // const SizedBox(height: 16),
            // const Text(
            //   'Upcoming Elections',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.orange,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // if (upcomingElections.isEmpty)
            //   const Card(
            //     child: Padding(
            //       padding: EdgeInsets.all(16.0),
            //       child: Center(
            //         child: Text('No upcoming elections'),
            //       ),
            //     ),
            //   )
            // else
            //   ...upcomingElections.map((election) => _buildElectionCard(election)),
            const SizedBox(height: 16),
            // const Text(
            //   'Past Elections',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.grey,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // if (pastElections.isEmpty)
            //   const Card(
            //     child: Padding(
            //       padding: EdgeInsets.all(16.0),
            //       child: Center(
            //         child: Text('No past elections'),
            //       ),
            //     ),
            //   )
            // else
            //   ...pastElections.map((election) => _buildElectionCard(election)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Elections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildElectionCard(Election election) {
    final now = DateTime.now();
    final bool isActive = election.startDate.isBefore(now) && election.endDate.isAfter(now);
    final bool isUpcoming = election.startDate.isAfter(now);
    
    Color borderColor = Colors.grey;
    if (isActive) borderColor = Colors.blue;
    if (isUpcoming) borderColor = Colors.orange;

    String status = 'Ended';
    if (isActive) status = 'Active';
    if (isUpcoming) status = 'Upcoming';

    Duration timeLeft = Duration.zero;
    String timeLeftText = '';
    
    if (isActive) {
      timeLeft = election.endDate.difference(now);
      timeLeftText = 'Ends in: ';
    } else if (isUpcoming) {
      timeLeft = election.startDate.difference(now);
      timeLeftText = 'Starts in: ';
    }

    String formatDuration(Duration duration) {
      if (duration.inDays > 0) {
        return '${duration.inDays} days ${duration.inHours % 24} hours';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
      } else {
        return '${duration.inMinutes} minutes';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${election.title} - ${election.department}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: isActive ? Colors.blue.shade100 : 
                                 isUpcoming ? Colors.orange.shade100 : 
                                 Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.blue.shade900 : 
                           isUpcoming ? Colors.orange.shade900 : 
                           Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isActive || isUpcoming)
              Text(
                '$timeLeftText${formatDuration(timeLeft)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.blue : Colors.orange,
                ),
              )
            else
              Text(
                'Ended on: ${DateFormat('MMM dd, yyyy').format(election.endDate)}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text('Candidates: ${election.candidates}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // View election details
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit election
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () {
                      // View live results
                    },
                    icon: const Icon(Icons.poll),
                    label: const Text('Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                    ),
                  )
                else if (!isUpcoming)
                  ElevatedButton.icon(
                    onPressed: () {
                      // View final results
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      // Manage candidates
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Candidates'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}