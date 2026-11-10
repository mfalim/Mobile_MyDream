import 'package:flutter_test/flutter_test.dart';
import 'package:w51/features/member/domain/entities/member_dashboard_data.dart';

void main() {
  test('MemberDashboardData parses backend response correctly', () {
    final sampleJson = {
      "data": {
        "member": {
          "id": 1,
          "user_id": 8,
          "member_code": "MBR001",
          "name": "BG Gamers",
          "call_sign": "bang",
          "phone": "0877237137232",
          "email": "babanggorenganyt@gmail.com",
          "domicile": "Jemner",
          "division": "show-management",
          "position": "Coordinator",
          "specialization": "Audio",
          "ht_code": "08h",
          "emergency_name": "Akef",
          "emergency_phone": "088723713612",
          "daily_fee": null,
          "status": "standby"
        },
        "schedules": [
          {
            "id": 15,
            "event_id": 2,
            "vendor_id": 3,
            "member_id": null,
            "activity": "Pakar Dekor",
            "location": null,
            "start_time": "2026-11-09T09:00:00.000000Z",
            "end_time": "2026-11-09T17:00:00.000000Z",
            "notes": null,
            "status": "pending",
            "event": {
              "id": 2,
              "booking_id": 2,
              "name": "Pernikahan Fattahul Alim & Lia Bilqis",
              "booking": {
                "venue_name": "Hotel Mulia Surya",
                "client": {
                  "groom_name": "Fattahul Alim",
                  "bride_name": "Lia Bilqis"
                }
              }
            },
            "vendor": {
              "name": "Pakar Dekor",
              "category": {"name": "Decoration"}
            }
          }
        ],
        "event_members": [
          {
            "id": 7,
            "event_id": 6,
            "member_id": 1,
            "role": "Coordinator",
            "attendance_status": "present",
            "actual_hours": "0.00",
            "total_fee": "0.00",
            "payment_status": "pending",
            "event": {
              "id": 6,
              "name": "Makan Resepsi",
              "booking": {
                "venue_name": "Hotel Mulia Surya",
                "client": {
                  "groom_name": "Fattahul Alim",
                  "bride_name": "Lia Bilqis"
                }
              },
              "event_members": [
                {
                  "id": 7,
                  "member_id": 1,
                  "role": "Coordinator",
                  "attendance_status": "present",
                  "member": {
                    "id": 1,
                    "name": "BG Gamers",
                    "call_sign": "bang",
                    "position": "Coordinator"
                  }
                }
              ]
            }
          }
        ],
        "stats": {
          "total_schedules": 4,
          "pending": 4,
          "approved": 0,
          "rejected": 0,
          "total_events": 2,
          "coordinator_events": 2,
          "approved_fee": 0,
          "estimated_fee": 0
        }
      }
    };

    final dashboardData = MemberDashboardData.fromJson(sampleJson);

    expect(dashboardData.member.name, 'BG Gamers');
    expect(dashboardData.member.callSign, 'bang');
    expect(dashboardData.member.positionName, 'Coordinator');

    expect(dashboardData.schedules.length, 1);
    expect(dashboardData.schedules.first.title, 'Pakar Dekor');
    expect(dashboardData.schedules.first.clientName, 'Fattahul Alim & Lia Bilqis');
    expect(dashboardData.schedules.first.vendorCategory, 'Decoration');

    expect(dashboardData.events.length, 1);
    expect(dashboardData.events.first.eventName, 'Makan Resepsi');
    expect(dashboardData.events.first.clientName, 'Fattahul Alim & Lia Bilqis');
    expect(dashboardData.events.first.isCoordinator, isTrue);
    expect(dashboardData.events.first.teamMembers.length, 1);
    expect(dashboardData.events.first.teamMembers.first.position, 'Coordinator');
  });
}

