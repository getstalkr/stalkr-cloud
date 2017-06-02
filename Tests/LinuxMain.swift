//
//  LinuxMain.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/1/17.
//
//

import XCTest

@testable import StalkrCloudTests

XCTMain([
    testCase(UserControllerTest.allTests),
    testCase(TeamControllerTest.allTests),
    testCase(TeamMembershipControllerTest.allTests),
    testCase(RoleControllerTest.allTests),
    testCase(RoleAssignmentControllerTest.allTests),
    testCase(UserTest.allTests),
    testCase(TeamTest.allTests)
    ])
