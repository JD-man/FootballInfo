//
//  ScheduleRouter.swift
//  FootballInfo
//
//  Created by 조동현 on 2022/11/29.
//

import RIBs

protocol ScheduleInteractable: Interactable {
  var router: ScheduleRouting? { get set }
  var listener: ScheduleListener? { get set }
}

protocol ScheduleViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ScheduleRouter: ViewableRouter<ScheduleInteractable, ScheduleViewControllable>, ScheduleRouting {
  
  // TODO: Constructor inject child builder protocols to allow building children.
  override init(interactor: ScheduleInteractable, viewController: ScheduleViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
