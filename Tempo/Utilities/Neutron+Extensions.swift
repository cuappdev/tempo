//
//  Neutron+Extensions.swift
//  Tempo
//
//  Created by Joseph Antonakakis on 8/23/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import Neutron

// Custom protocol with a default host
public protocol TempoRequest: JSONQuark {}
extension TempoRequest {
	var host: String {
		return "http://localhost:5000"
	}
}
