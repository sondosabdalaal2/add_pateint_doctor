import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_health/constants.dart';
import 'package:my_health/components/addButton.dart';

class AddPatientDoctor extends StatefulWidget {
  @override
  _AddPatientDoctorState createState() => _AddPatientDoctorState();
}

class _AddPatientDoctorState extends State<AddPatientDoctor> {
  var selectedDoctor;

  void _onPressed(String uid, String doctorName) {
    var firebaseUser = uid;
    FirebaseFirestore.instance.collection("Patients").doc(firebaseUser).update({
      'doctor': doctorName,
    }).then((_) {
      print("success!");
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
    FirebaseFirestore.instance.collection('Patients');

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot patientDocument) {
            return InkWell(
              onTap: () {
// ignore: missing_return
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    builder: (builder) {
                      CollectionReference doctors =
                      FirebaseFirestore.instance.collection('Doctors');
                      return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
//color: Colors.white,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: doctors.snapshots(),
// ignore: missing_return
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading");
                              } else {
                                List<DropdownMenuItem> chooseDoctor = [];
                                for (int i = 0;
                                i < snapshot.data.docs.length;
                                i++) {
                                  DocumentSnapshot snap = snapshot.data.docs[i];
                                  chooseDoctor.add(
                                    DropdownMenuItem(
                                      child: Text(
                                        snap.data()['fullName'],
                                        style: TextStyle(color: kPrimaryColor),
                                      ),
                                      value: "${snap.data()['fullName']}",
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    Text('Choose Doctor ... '),
                                    DropdownButton(
                                      items: chooseDoctor,
                                      onChanged: (doctor) {
                                        selectedDoctor = doctor;
// _onPressed(patientDocument.data()['uid'], selectedDoctor.data()['fullName']);
                                      },
                                      value: selectedDoctor,
                                      isExpanded: false,
                                      hint: Text(
                                        "Choose Doctor",
                                        style: TextStyle(color: kPrimaryColor),
                                      ),
                                    ),
                                    AddButton(
                                      text: 'Add',
                                      press: () async {
                                        _onPressed(
                                            patientDocument.data()['uid'],
                                            selectedDoctor.data()['fullName']);
                                      },
                                    )

                                  ],
                                );
                              }
                            },
                          ));
                    });
              },
              child: ListTile(
                title: Text(patientDocument.data()['fullName']),
                subtitle: Text(patientDocument.data()['email']),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}