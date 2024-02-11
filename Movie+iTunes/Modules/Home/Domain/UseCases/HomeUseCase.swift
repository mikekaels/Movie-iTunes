//
//  HomeUseCase.swift
//  Movie+iTunes
//
//  Created by Santo Michael on 11/02/24.
//

import Combine

internal protocol HomeUseCaseProtocol {
	func getFavorites() -> [Movie]
}

internal final class HomeUseCase {
	
}

extension HomeUseCase: HomeUseCaseProtocol {
	func getFavorites() -> [Movie] {
		[
			.init(title: "Star Trek Into Darkness",
				  description: "J.J. Abrams STAR TREK INTO DARKNESS is the best-reviewed blockbuster of the year. When a ruthless",
				  year: "2013-05-17T07:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video127/v4/d1/d4/7a/d1d47a23-7ed3-f51d-ded1-12ab6ea3d5c6/mzvf_6689004818574290975.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video127/v4/c3/00/10/c30010bb-989c-3ce0-e100-9fb4f9f631d4/pr_source.jpg/300x300bb.jpg",
				  image: nil),
			.init(title: "Star Wars: The Force Awakens",
				  description: "Lucasfilm and visionary director J.J. Abrams join forces to take you back again to a galaxy far, far",
				  year: "2015-12-18T08:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video82/v4/a3/ef/25/a3ef253a-208e-3cbc-cbf0-bc444dae2f8d/mzvf_6313901593442783545.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video123/v4/1f/2b/ae/1f2bae7f-62a1-1055-8471-401291b6dcdd/pr_source.lsr/300x300bb.jpg",
				  image: nil),
			.init(title: "Star Trek Into Darkne",
				  description: "J.J. Abrams STAR TREK INTO DARKNESS is the best-reviewed blockbuster of the year. When a ruthless",
				  year: "2013-05-17T07:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video127/v4/d1/d4/7a/d1d47a23-7ed3-f51d-ded1-12ab6ea3d5c6/mzvf_6689004818574290975.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video127/v4/c3/00/10/c30010bb-989c-3ce0-e100-9fb4f9f631d4/pr_source.jpg/300x300bb.jpg",
				  image: nil),
			.init(title: "Star Wars: The Force Awake",
				  description: "Lucasfilm and visionary director J.J. Abrams join forces to take you back again to a galaxy far, far",
				  year: "2015-12-18T08:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video82/v4/a3/ef/25/a3ef253a-208e-3cbc-cbf0-bc444dae2f8d/mzvf_6313901593442783545.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video123/v4/1f/2b/ae/1f2bae7f-62a1-1055-8471-401291b6dcdd/pr_source.lsr/300x300bb.jpg",
				  image: nil),
			.init(title: "Star ek Into Darkness",
				  description: "J.J. Abrams STAR TREK INTO DARKNESS is the best-reviewed blockbuster of the year. When a ruthless",
				  year: "2013-05-17T07:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video127/v4/d1/d4/7a/d1d47a23-7ed3-f51d-ded1-12ab6ea3d5c6/mzvf_6689004818574290975.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video127/v4/c3/00/10/c30010bb-989c-3ce0-e100-9fb4f9f631d4/pr_source.jpg/300x300bb.jpg",
				  image: nil),
			.init(title: "Star Ws: The Force Awakens",
				  description: "Lucasfilm and visionary director J.J. Abrams join forces to take you back again to a galaxy far, far",
				  year: "2015-12-18T08:00:00Z",
				  trailer: "https://video-ssl.itunes.apple.com/itunes-assets/Video82/v4/a3/ef/25/a3ef253a-208e-3cbc-cbf0-bc444dae2f8d/mzvf_6313901593442783545.640x354.h264lc.U.p.m4v",
				  posterPath: "https://is1-ssl.mzstatic.com/image/thumb/Video123/v4/1f/2b/ae/1f2bae7f-62a1-1055-8471-401291b6dcdd/pr_source.lsr/300x300bb.jpg",
				  image: nil),
		]
	}
}
