/// Looks up generated Material icon code points by their Flutter names.
final class IconCatalog {
  const IconCatalog._();

  static int? codePoint(Object? name) =>
      name is String ? _codePoints[name] : null;

  static const Map<String, int> _codePoints = {
    'abc': 0xf04b6, // action — absent, alphabet, bare, blank, character
    'abc_outlined':
        0xf05b1, // [outline] action — absent, alphabet, bare, blank, character
    'abc_rounded':
        0xe4c4, // [round] action — absent, alphabet, bare, blank, character
    'abc_sharp':
        0xf03c3, // [sharp] action — absent, alphabet, bare, blank, character
    'ac_unit': 0xe037, // places — ac, air, air conditioning, asterisk, climate
    'ac_unit_outlined':
        0xee29, // [outline] places — ac, air, air conditioning, asterisk, climate
    'ac_unit_rounded':
        0xf516, // [round] places — ac, air, air conditioning, asterisk, climate
    'ac_unit_sharp':
        0xe737, // [sharp] places — ac, air, air conditioning, asterisk, climate
    'access_alarm':
        0xe038, // device — access, adjust, alarm, alert, appointment
    'access_alarm_outlined':
        0xee2a, // [outline] device — access, adjust, alarm, alert, appointment
    'access_alarm_rounded':
        0xf517, // [round] device — access, adjust, alarm, alert, appointment
    'access_alarm_sharp':
        0xe738, // [sharp] device — access, adjust, alarm, alert, appointment
    'access_alarms':
        0xe039, // device — access, adjust, alarm, alert, appointment
    'access_alarms_outlined':
        0xee2b, // [outline] device — access, adjust, alarm, alert, appointment
    'access_alarms_rounded':
        0xf518, // [round] device — access, adjust, alarm, alert, appointment
    'access_alarms_sharp':
        0xe739, // [sharp] device — access, adjust, alarm, alert, appointment
    'access_time':
        0xe03a, // device — alarm, appointment, calendar, chronometer, clock
    'access_time_filled':
        0xe03b, // device — alarm, appointment, calendar, chronometer, clock
    'access_time_filled_outlined':
        0xee2c, // [outline] device — alarm, appointment, calendar, chronometer, clock
    'access_time_filled_rounded':
        0xf519, // [round] device — alarm, appointment, calendar, chronometer, clock
    'access_time_filled_sharp':
        0xe73a, // [sharp] device — alarm, appointment, calendar, chronometer, clock
    'access_time_outlined':
        0xee2d, // [outline] device — alarm, appointment, calendar, chronometer, clock
    'access_time_rounded':
        0xf51a, // [round] device — alarm, appointment, calendar, chronometer, clock
    'access_time_sharp':
        0xe73b, // [sharp] device — alarm, appointment, calendar, chronometer, clock
    'accessibility':
        0xe03c, // action — access, accessibility, accessible, aid, assistance
    'accessibility_new':
        0xe03d, // action — access, accessibility, accessible, assistance, barrier-free
    'accessibility_new_outlined':
        0xee2e, // [outline] action — access, accessibility, accessible, assistance, barrier-free
    'accessibility_new_rounded':
        0xf51b, // [round] action — access, accessibility, accessible, assistance, barrier-free
    'accessibility_new_sharp':
        0xe73c, // [sharp] action — access, accessibility, accessible, assistance, barrier-free
    'accessibility_outlined':
        0xee2f, // [outline] action — access, accessibility, accessible, aid, assistance
    'accessibility_rounded':
        0xf51c, // [round] action — access, accessibility, accessible, aid, assistance
    'accessibility_sharp':
        0xe73d, // [sharp] action — access, accessibility, accessible, aid, assistance
    'accessible':
        0xe03e, // action — accessibility, accessible, assistance, body, disability
    'accessible_forward':
        0xe03f, // action — accessibility, accessible, arrow, arrow right, body
    'accessible_forward_outlined':
        0xee30, // [outline] action — accessibility, accessible, arrow, arrow right, body
    'accessible_forward_rounded':
        0xf51d, // [round] action — accessibility, accessible, arrow, arrow right, body
    'accessible_forward_sharp':
        0xe73e, // [sharp] action — accessibility, accessible, arrow, arrow right, body
    'accessible_outlined':
        0xee31, // [outline] action — accessibility, accessible, assistance, body, disability
    'accessible_rounded':
        0xf51e, // [round] action — accessibility, accessible, assistance, body, disability
    'accessible_sharp':
        0xe73f, // [sharp] action — accessibility, accessible, assistance, body, disability
    'account_balance':
        0xe040, // action — account, accounting, balance, bank, banking
    'account_balance_outlined':
        0xee32, // [outline] action — account, accounting, balance, bank, banking
    'account_balance_rounded':
        0xf51f, // [round] action — account, accounting, balance, bank, banking
    'account_balance_sharp':
        0xe740, // [sharp] action — account, accounting, balance, bank, banking
    'account_balance_wallet':
        0xe041, // action — account, assets, balance, bank, banking
    'account_balance_wallet_outlined':
        0xee33, // [outline] action — account, assets, balance, bank, banking
    'account_balance_wallet_rounded':
        0xf520, // [round] action — account, assets, balance, bank, banking
    'account_balance_wallet_sharp':
        0xe741, // [sharp] action — account, assets, balance, bank, banking
    'account_box': 0xe042, // action — account, accounts, avatar, box, bust
    'account_box_outlined':
        0xee34, // [outline] action — account, accounts, avatar, box, bust
    'account_box_rounded':
        0xf521, // [round] action — account, accounts, avatar, box, bust
    'account_box_sharp':
        0xe742, // [sharp] action — account, accounts, avatar, box, bust
    'account_circle':
        0xe043, // action — account, account circle, account details, account management, account settings
    'account_circle_outlined':
        0xee35, // [outline] action — account, account circle, account details, account management, account settings
    'account_circle_rounded':
        0xf522, // [round] action — account, account circle, account details, account management, account settings
    'account_circle_sharp':
        0xe743, // [sharp] action — account, account circle, account details, account management, account settings
    'account_tree':
        0xe044, // notification — account, account structure, analytics, branches, chart
    'account_tree_outlined':
        0xee36, // [outline] notification — account, account structure, analytics, branches, chart
    'account_tree_rounded':
        0xf523, // [round] notification — account, account structure, analytics, branches, chart
    'account_tree_sharp':
        0xe744, // [sharp] notification — account, account structure, analytics, branches, chart
    'ad_units': 0xe045, // device — Android, OS, ad, ad units, advertising
    'ad_units_outlined':
        0xee37, // [outline] device — Android, OS, ad, ad units, advertising
    'ad_units_rounded':
        0xf524, // [round] device — Android, OS, ad, ad units, advertising
    'ad_units_sharp':
        0xe745, // [sharp] device — Android, OS, ad, ad units, advertising
    'adb': 0xe046, // notification — adb, android, bridge, bug, code
    'adb_outlined':
        0xee38, // [outline] notification — adb, android, bridge, bug, code
    'adb_rounded':
        0xf525, // [round] notification — adb, android, bridge, bug, code
    'adb_sharp':
        0xe746, // [sharp] notification — adb, android, bridge, bug, code
    'add': 0xe047, // content — +, add, addition, append, arithmetic
    'add_a_photo': 0xe048, // image — +, a photo, add, album, camera
    'add_a_photo_outlined':
        0xee39, // [outline] image — +, a photo, add, album, camera
    'add_a_photo_rounded':
        0xf526, // [round] image — +, a photo, add, album, camera
    'add_a_photo_sharp':
        0xe747, // [sharp] image — +, a photo, add, album, camera
    'add_alarm': 0xe049, // device — add, add alarm, alarm, alert, appointment
    'add_alarm_outlined':
        0xee3a, // [outline] device — add, add alarm, alarm, alert, appointment
    'add_alarm_rounded':
        0xf527, // [round] device — add, add alarm, alarm, alert, appointment
    'add_alarm_sharp':
        0xe748, // [sharp] device — add, add alarm, alarm, alert, appointment
    'add_alert': 0xe04a, // alert — +, active, add, add attention, add important
    'add_alert_outlined':
        0xee3b, // [outline] alert — +, active, add, add attention, add important
    'add_alert_rounded':
        0xf528, // [round] alert — +, active, add, add attention, add important
    'add_alert_sharp':
        0xe749, // [sharp] alert — +, active, add, add attention, add important
    'add_box': 0xe04b, // content — add, addition, box, build, construct
    'add_box_outlined':
        0xee3c, // [outline] content — add, addition, box, build, construct
    'add_box_rounded':
        0xf529, // [round] content — add, addition, box, build, construct
    'add_box_sharp':
        0xe74a, // [sharp] content — add, addition, box, build, construct
    'add_business':
        0xe04c, // maps — +, add, add building, add business, add business location
    'add_business_outlined':
        0xee3d, // [outline] maps — +, add, add building, add business, add business location
    'add_business_rounded':
        0xf52a, // [round] maps — +, add, add building, add business, add business location
    'add_business_sharp':
        0xe74b, // [sharp] maps — +, add, add building, add business, add business location
    'add_call': 0xe04d, // notification — +, add, add call, call, cell
    'add_card': 0xf04b7, // action — +, account, add, add card, add credit card
    'add_card_outlined':
        0xf05b2, // [outline] action — +, account, add, add card, add credit card
    'add_card_rounded':
        0xf02d1, // [round] action — +, account, add, add card, add credit card
    'add_card_sharp':
        0xf03c4, // [sharp] action — +, account, add, add card, add credit card
    'add_chart': 0xe04e, // editor — +, add, analysis, analytics, bar
    'add_chart_outlined':
        0xee3e, // [outline] editor — +, add, analysis, analytics, bar
    'add_chart_rounded':
        0xf52b, // [round] editor — +, add, analysis, analytics, bar
    'add_chart_sharp':
        0xe74c, // [sharp] editor — +, add, analysis, analytics, bar
    'add_circle': 0xe04f, // content — +, add, append, circle, circular
    'add_circle_outline': 0xe050, // content — +, add, append, circle, circular
    'add_circle_outline_outlined':
        0xee3f, // [outline] content — +, add, append, circle, circular
    'add_circle_outline_rounded':
        0xf52c, // [round] content — +, add, append, circle, circular
    'add_circle_outline_sharp':
        0xe74d, // [sharp] content — +, add, append, circle, circular
    'add_circle_outlined':
        0xee40, // [outline] content — +, add, append, circle, circular
    'add_circle_rounded':
        0xf52d, // [round] content — +, add, append, circle, circular
    'add_circle_sharp':
        0xe74e, // [sharp] content — +, add, append, circle, circular
    'add_comment': 0xe051, // editor — +, add, annotation, append, bubble
    'add_comment_outlined':
        0xee41, // [outline] editor — +, add, annotation, append, bubble
    'add_comment_rounded':
        0xf52e, // [round] editor — +, add, annotation, append, bubble
    'add_comment_sharp':
        0xe74f, // [sharp] editor — +, add, annotation, append, bubble
    'add_home':
        0xf0785, // action — accommodation, add, append, architecture, attach
    'add_home_outlined':
        0xf06d5, // [outline] action — accommodation, add, append, architecture, attach
    'add_home_rounded':
        0xf07dd, // [round] action — accommodation, add, append, architecture, attach
    'add_home_sharp':
        0xf072d, // [sharp] action — accommodation, add, append, architecture, attach
    'add_home_work':
        0xf0786, // navigation — add, add building, add business, add home, add house
    'add_home_work_outlined':
        0xf06d6, // [outline] navigation — add, add building, add business, add home, add house
    'add_home_work_rounded':
        0xf07de, // [round] navigation — add, add building, add business, add home, add house
    'add_home_work_sharp':
        0xf072e, // [sharp] navigation — add, add building, add business, add home, add house
    'add_ic_call': 0xe052, // communication — +, add, add call, call, cell
    'add_ic_call_outlined':
        0xee42, // [outline] communication — +, add, add call, call, cell
    'add_ic_call_rounded':
        0xf52f, // [round] communication — +, add, add call, call, cell
    'add_ic_call_sharp':
        0xe750, // [sharp] communication — +, add, add call, call, cell
    'add_link': 0xe053, // content — add, add link, anchor, associate, attach
    'add_link_outlined':
        0xee43, // [outline] content — add, add link, anchor, associate, attach
    'add_link_rounded':
        0xf530, // [round] content — add, add link, anchor, associate, attach
    'add_link_sharp':
        0xe751, // [sharp] content — add, add link, anchor, associate, attach
    'add_location': 0xe054, // maps — +, add, address, check in, coordinate
    'add_location_alt': 0xe055, // maps — +, add, address, coordinate, create
    'add_location_alt_outlined':
        0xee44, // [outline] maps — +, add, address, coordinate, create
    'add_location_alt_rounded':
        0xf531, // [round] maps — +, add, address, coordinate, create
    'add_location_alt_sharp':
        0xe752, // [sharp] maps — +, add, address, coordinate, create
    'add_location_outlined':
        0xee45, // [outline] maps — +, add, address, check in, coordinate
    'add_location_rounded':
        0xf532, // [round] maps — +, add, address, check in, coordinate
    'add_location_sharp':
        0xe753, // [sharp] maps — +, add, address, check in, coordinate
    'add_moderator':
        0xe056, // social — +, add, add administrator, add member, add moderator
    'add_moderator_outlined':
        0xee46, // [outline] social — +, add, add administrator, add member, add moderator
    'add_moderator_rounded':
        0xf533, // [round] social — +, add, add administrator, add member, add moderator
    'add_moderator_sharp':
        0xe754, // [sharp] social — +, add, add administrator, add member, add moderator
    'add_outlined':
        0xee47, // [outline] content — +, add, addition, append, arithmetic
    'add_photo_alternate': 0xe057, // image — +, add, addition, album, alternate
    'add_photo_alternate_outlined':
        0xee48, // [outline] image — +, add, addition, album, alternate
    'add_photo_alternate_rounded':
        0xf534, // [round] image — +, add, addition, album, alternate
    'add_photo_alternate_sharp':
        0xe755, // [sharp] image — +, add, addition, album, alternate
    'add_reaction':
        0xe058, // social — +, add, add emotion, add feeling, add reaction
    'add_reaction_outlined':
        0xee49, // [outline] social — +, add, add emotion, add feeling, add reaction
    'add_reaction_rounded':
        0xf535, // [round] social — +, add, add emotion, add feeling, add reaction
    'add_reaction_sharp':
        0xe756, // [sharp] social — +, add, add emotion, add feeling, add reaction
    'add_road': 0xe059, // maps — +, add, add new, build, create
    'add_road_outlined':
        0xee4a, // [outline] maps — +, add, add new, build, create
    'add_road_rounded': 0xf536, // [round] maps — +, add, add new, build, create
    'add_road_sharp': 0xe757, // [sharp] maps — +, add, add new, build, create
    'add_rounded':
        0xf537, // [round] content — +, add, addition, append, arithmetic
    'add_sharp':
        0xe758, // [sharp] content — +, add, addition, append, arithmetic
    'add_shopping_cart':
        0xe05a, // action — acquisition, add, add to cart, basket, buy
    'add_shopping_cart_outlined':
        0xee4b, // [outline] action — acquisition, add, add to cart, basket, buy
    'add_shopping_cart_rounded':
        0xf538, // [round] action — acquisition, add, add to cart, basket, buy
    'add_shopping_cart_sharp':
        0xe759, // [sharp] action — acquisition, add, add to cart, basket, buy
    'add_task': 0xe05b, // action — +, accept, add, addition, agenda
    'add_task_outlined':
        0xee4c, // [outline] action — +, accept, add, addition, agenda
    'add_task_rounded':
        0xf539, // [round] action — +, accept, add, addition, agenda
    'add_task_sharp':
        0xe75a, // [sharp] action — +, accept, add, addition, agenda
    'add_to_drive': 0xe05c, // action — account, add, archive, backup, cloud
    'add_to_drive_outlined':
        0xee4d, // [outline] action — account, add, archive, backup, cloud
    'add_to_drive_rounded':
        0xf53a, // [round] action — account, add, archive, backup, cloud
    'add_to_drive_sharp':
        0xe75b, // [sharp] action — account, add, archive, backup, cloud
    'add_to_home_screen':
        0xe05d, // device — Android, OS, add, add to, add to homescreen
    'add_to_home_screen_outlined':
        0xee4e, // [outline] device — Android, OS, add, add to, add to homescreen
    'add_to_home_screen_rounded':
        0xf53b, // [round] device — Android, OS, add, add to, add to homescreen
    'add_to_home_screen_sharp':
        0xe75c, // [sharp] device — Android, OS, add, add to, add to homescreen
    'add_to_photos': 0xe05e, // image — add, album, append, camera, capture
    'add_to_photos_outlined':
        0xee4f, // [outline] image — add, album, append, camera, capture
    'add_to_photos_rounded':
        0xf53c, // [round] image — add, album, append, camera, capture
    'add_to_photos_sharp':
        0xe75d, // [sharp] image — add, album, append, camera, capture
    'add_to_queue': 0xe05f, // av — +, Android, OS, add, add to queue
    'add_to_queue_outlined':
        0xee50, // [outline] av — +, Android, OS, add, add to queue
    'add_to_queue_rounded':
        0xf53d, // [round] av — +, Android, OS, add, add to queue
    'add_to_queue_sharp':
        0xe75e, // [sharp] av — +, Android, OS, add, add to queue
    'addchart': 0xe060, // action — +, add, addchart, analysis, analytics
    'addchart_outlined':
        0xee51, // [outline] action — +, add, addchart, analysis, analytics
    'addchart_rounded':
        0xf53e, // [round] action — +, add, addchart, analysis, analytics
    'addchart_sharp':
        0xe75f, // [sharp] action — +, add, addchart, analysis, analytics
    'adf_scanner':
        0xf04b8, // hardware — adf, adf scanner, business, copier, copy
    'adf_scanner_outlined':
        0xf05b3, // [outline] hardware — adf, adf scanner, business, copier, copy
    'adf_scanner_rounded':
        0xf02d2, // [round] hardware — adf, adf scanner, business, copier, copy
    'adf_scanner_sharp':
        0xf03c5, // [sharp] hardware — adf, adf scanner, business, copier, copy
    'adjust': 0xe061, // image — adjust, alter, auto click, bar, bars
    'adjust_outlined':
        0xee52, // [outline] image — adjust, alter, auto click, bar, bars
    'adjust_rounded':
        0xf53f, // [round] image — adjust, alter, auto click, bar, bars
    'adjust_sharp':
        0xe760, // [sharp] image — adjust, alter, auto click, bar, bars
    'admin_panel_settings':
        0xe062, // action — access, account, adjust, admin, administrator
    'admin_panel_settings_outlined':
        0xee53, // [outline] action — access, account, adjust, admin, administrator
    'admin_panel_settings_rounded':
        0xf540, // [round] action — access, account, adjust, admin, administrator
    'admin_panel_settings_sharp':
        0xe761, // [sharp] action — access, account, adjust, admin, administrator
    'adobe': 0xf04b9, // brand logo
    'adobe_outlined': 0xf05b4, // [outline] brand logo
    'adobe_rounded': 0xf02d3, // [round] brand logo
    'adobe_sharp': 0xf03c6, // [sharp] brand logo
    'ads_click':
        0xf04ba, // action — ads, ads click, advertisement, analytics, arrow
    'ads_click_outlined':
        0xf05b5, // [outline] action — ads, ads click, advertisement, analytics, arrow
    'ads_click_rounded':
        0xf02d4, // [round] action — ads, ads click, advertisement, analytics, arrow
    'ads_click_sharp':
        0xf03c7, // [sharp] action — ads, ads click, advertisement, analytics, arrow
    'agriculture':
        0xe063, // maps — agriculture, automobile, botanical, car, cars
    'agriculture_outlined':
        0xee54, // [outline] maps — agriculture, automobile, botanical, car, cars
    'agriculture_rounded':
        0xf541, // [round] maps — agriculture, automobile, botanical, car, cars
    'agriculture_sharp':
        0xe762, // [sharp] maps — agriculture, automobile, botanical, car, cars
    'air': 0xe064, // device — abstract, air, atmospheric, blowing, breath
    'air_outlined':
        0xee55, // [outline] device — abstract, air, atmospheric, blowing, breath
    'air_rounded':
        0xf542, // [round] device — abstract, air, atmospheric, blowing, breath
    'air_sharp':
        0xe763, // [sharp] device — abstract, air, atmospheric, blowing, breath
    'airline_seat_flat':
        0xe065, // notification — airline, airplane, aviation, bed, body
    'airline_seat_flat_angled':
        0xe066, // notification — abstract., airline, airplane, angled, bed
    'airline_seat_flat_angled_outlined':
        0xee56, // [outline] notification — abstract., airline, airplane, angled, bed
    'airline_seat_flat_angled_rounded':
        0xf543, // [round] notification — abstract., airline, airplane, angled, bed
    'airline_seat_flat_angled_sharp':
        0xe764, // [sharp] notification — abstract., airline, airplane, angled, bed
    'airline_seat_flat_outlined':
        0xee57, // [outline] notification — airline, airplane, aviation, bed, body
    'airline_seat_flat_rounded':
        0xf544, // [round] notification — airline, airplane, aviation, bed, body
    'airline_seat_flat_sharp':
        0xe765, // [sharp] notification — airline, airplane, aviation, bed, body
    'airline_seat_individual_suite':
        0xe067, // notification — aircraft, airline, airplane, aisle, aviation
    'airline_seat_individual_suite_outlined':
        0xee58, // [outline] notification — aircraft, airline, airplane, aisle, aviation
    'airline_seat_individual_suite_rounded':
        0xf545, // [round] notification — aircraft, airline, airplane, aisle, aviation
    'airline_seat_individual_suite_sharp':
        0xe766, // [sharp] notification — aircraft, airline, airplane, aisle, aviation
    'airline_seat_legroom_extra':
        0xe068, // notification — airline, airplane, body, booking, chair
    'airline_seat_legroom_extra_outlined':
        0xee59, // [outline] notification — airline, airplane, body, booking, chair
    'airline_seat_legroom_extra_rounded':
        0xf546, // [round] notification — airline, airplane, body, booking, chair
    'airline_seat_legroom_extra_sharp':
        0xe767, // [sharp] notification — airline, airplane, body, booking, chair
    'airline_seat_legroom_normal':
        0xe069, // notification — airline, airplane, area, arrangement, aviation
    'airline_seat_legroom_normal_outlined':
        0xee5a, // [outline] notification — airline, airplane, area, arrangement, aviation
    'airline_seat_legroom_normal_rounded':
        0xf547, // [round] notification — airline, airplane, area, arrangement, aviation
    'airline_seat_legroom_normal_sharp':
        0xe768, // [sharp] notification — airline, airplane, area, arrangement, aviation
    'airline_seat_legroom_reduced':
        0xe06a, // notification — aircraft, airline, airplane, body, cabin
    'airline_seat_legroom_reduced_outlined':
        0xee5b, // [outline] notification — aircraft, airline, airplane, body, cabin
    'airline_seat_legroom_reduced_rounded':
        0xf548, // [round] notification — aircraft, airline, airplane, body, cabin
    'airline_seat_legroom_reduced_sharp':
        0xe769, // [sharp] notification — aircraft, airline, airplane, body, cabin
    'airline_seat_recline_extra':
        0xe06b, // notification — airline, airplane, aviation, body, booking
    'airline_seat_recline_extra_outlined':
        0xee5c, // [outline] notification — airline, airplane, aviation, body, booking
    'airline_seat_recline_extra_rounded':
        0xf549, // [round] notification — airline, airplane, aviation, body, booking
    'airline_seat_recline_extra_sharp':
        0xe76a, // [sharp] notification — airline, airplane, aviation, body, booking
    'airline_seat_recline_normal':
        0xe06c, // notification — airline, airline diagram, airline layout, airplane, body
    'airline_seat_recline_normal_outlined':
        0xee5d, // [outline] notification — airline, airline diagram, airline layout, airplane, body
    'airline_seat_recline_normal_rounded':
        0xf54a, // [round] notification — airline, airline diagram, airline layout, airplane, body
    'airline_seat_recline_normal_sharp':
        0xe76b, // [sharp] notification — airline, airline diagram, airline layout, airplane, body
    'airline_stops':
        0xf04bb, // maps — airline, airplane, airport, arrow, aviation
    'airline_stops_outlined':
        0xf05b6, // [outline] maps — airline, airplane, airport, arrow, aviation
    'airline_stops_rounded':
        0xf02d5, // [round] maps — airline, airplane, airport, arrow, aviation
    'airline_stops_sharp':
        0xf03c8, // [sharp] maps — airline, airplane, airport, arrow, aviation
    'airlines': 0xf04bc, // maps — air, air travel, aircraft, airlines, airplane
    'airlines_outlined':
        0xf05b7, // [outline] maps — air, air travel, aircraft, airlines, airplane
    'airlines_rounded':
        0xf02d6, // [round] maps — air, air travel, aircraft, airlines, airplane
    'airlines_sharp':
        0xf03c9, // [sharp] maps — air, air travel, aircraft, airlines, airplane
    'airplane_ticket':
        0xe06d, // device — admit, air, air ticket, aircraft, airplane
    'airplane_ticket_outlined':
        0xee5e, // [outline] device — admit, air, air ticket, aircraft, airplane
    'airplane_ticket_rounded':
        0xf54b, // [round] device — admit, air, air ticket, aircraft, airplane
    'airplane_ticket_sharp':
        0xe76c, // [sharp] device — admit, air, air ticket, aircraft, airplane
    'airplanemode_active':
        0xe06e, // device — active, air, air travel, aircraft, airplane
    'airplanemode_active_outlined':
        0xee5f, // [outline] device — active, air, air travel, aircraft, airplane
    'airplanemode_active_rounded':
        0xf54c, // [round] device — active, air, air travel, aircraft, airplane
    'airplanemode_active_sharp':
        0xe76d, // [sharp] device — active, air, air travel, aircraft, airplane
    'airplanemode_inactive':
        0xe06f, // device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_inactive_outlined':
        0xee60, // [outline] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_inactive_rounded':
        0xf54d, // [round] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_inactive_sharp':
        0xe76e, // [sharp] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_off':
        0xe06f, // device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_off_outlined':
        0xee60, // [outline] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_off_rounded':
        0xf54d, // [round] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_off_sharp':
        0xe76e, // [sharp] device — air, aircraft, airplane, airplane mode, airplanes
    'airplanemode_on':
        0xe06e, // device — active, air, air travel, aircraft, airplane
    'airplanemode_on_outlined':
        0xee5f, // [outline] device — active, air, air travel, aircraft, airplane
    'airplanemode_on_rounded':
        0xf54c, // [round] device — active, air, air travel, aircraft, airplane
    'airplanemode_on_sharp':
        0xe76d, // [sharp] device — active, air, air travel, aircraft, airplane
    'airplay': 0xe070, // av — airplay, arrow, audio, broadcast, cast screen
    'airplay_outlined':
        0xee61, // [outline] av — airplay, arrow, audio, broadcast, cast screen
    'airplay_rounded':
        0xf54e, // [round] av — airplay, arrow, audio, broadcast, cast screen
    'airplay_sharp':
        0xe76f, // [sharp] av — airplay, arrow, audio, broadcast, cast screen
    'airport_shuttle':
        0xe071, // places — airport, arrival, automobile, baggage, bus
    'airport_shuttle_outlined':
        0xee62, // [outline] places — airport, arrival, automobile, baggage, bus
    'airport_shuttle_rounded':
        0xf54f, // [round] places — airport, arrival, automobile, baggage, bus
    'airport_shuttle_sharp':
        0xe770, // [sharp] places — airport, arrival, automobile, baggage, bus
    'alarm': 0xe072, // action — access, adjust, alarm, alert, appointment
    'alarm_add': 0xe073, // action — +, add, add alarm, alarm, alert
    'alarm_add_outlined':
        0xee63, // [outline] action — +, add, add alarm, alarm, alert
    'alarm_add_rounded':
        0xf550, // [round] action — +, add, add alarm, alarm, alert
    'alarm_add_sharp':
        0xe771, // [sharp] action — +, add, add alarm, alarm, alert
    'alarm_off':
        0xe074, // action — alarm, alarm off, alert, bell, bell disabled
    'alarm_off_outlined':
        0xee64, // [outline] action — alarm, alarm off, alert, bell, bell disabled
    'alarm_off_rounded':
        0xf551, // [round] action — alarm, alarm off, alert, bell, bell disabled
    'alarm_off_sharp':
        0xe772, // [sharp] action — alarm, alarm off, alert, bell, bell disabled
    'alarm_on': 0xe075, // action — activated, active, alarm, alert, audible
    'alarm_on_outlined':
        0xee65, // [outline] action — activated, active, alarm, alert, audible
    'alarm_on_rounded':
        0xf552, // [round] action — activated, active, alarm, alert, audible
    'alarm_on_sharp':
        0xe773, // [sharp] action — activated, active, alarm, alert, audible
    'alarm_outlined':
        0xee66, // [outline] action — access, adjust, alarm, alert, appointment
    'alarm_rounded':
        0xf553, // [round] action — access, adjust, alarm, alert, appointment
    'alarm_sharp':
        0xe774, // [sharp] action — access, adjust, alarm, alert, appointment
    'album': 0xe076, // av — album, archive, artist, artwork, audio
    'album_outlined':
        0xee67, // [outline] av — album, archive, artist, artwork, audio
    'album_rounded':
        0xf554, // [round] av — album, archive, artist, artwork, audio
    'album_sharp':
        0xe775, // [sharp] av — album, archive, artist, artwork, audio
    'align_horizontal_center':
        0xe077, // editor — align, alignment, arrange, bars, center
    'align_horizontal_center_outlined':
        0xee68, // [outline] editor — align, alignment, arrange, bars, center
    'align_horizontal_center_rounded':
        0xf555, // [round] editor — align, alignment, arrange, bars, center
    'align_horizontal_center_sharp':
        0xe776, // [sharp] editor — align, alignment, arrange, bars, center
    'align_horizontal_left':
        0xe078, // editor — align, align horizontal, align left, alignment, arrange
    'align_horizontal_left_outlined':
        0xee69, // [outline] editor — align, align horizontal, align left, alignment, arrange
    'align_horizontal_left_rounded':
        0xf556, // [round] editor — align, align horizontal, align left, alignment, arrange
    'align_horizontal_left_sharp':
        0xe777, // [sharp] editor — align, align horizontal, align left, alignment, arrange
    'align_horizontal_right':
        0xe079, // editor — adjustment, align, alignment, arrange, bars
    'align_horizontal_right_outlined':
        0xee6a, // [outline] editor — adjustment, align, alignment, arrange, bars
    'align_horizontal_right_rounded':
        0xf557, // [round] editor — adjustment, align, alignment, arrange, bars
    'align_horizontal_right_sharp':
        0xe778, // [sharp] editor — adjustment, align, alignment, arrange, bars
    'align_vertical_bottom':
        0xe07a, // editor — align, alignment, arrange, bar, bottom
    'align_vertical_bottom_outlined':
        0xee6b, // [outline] editor — align, alignment, arrange, bar, bottom
    'align_vertical_bottom_rounded':
        0xf558, // [round] editor — align, alignment, arrange, bar, bottom
    'align_vertical_bottom_sharp':
        0xe779, // [sharp] editor — align, alignment, arrange, bar, bottom
    'align_vertical_center':
        0xe07b, // editor — align, alignment, arrangement, blocks, center
    'align_vertical_center_outlined':
        0xee6c, // [outline] editor — align, alignment, arrangement, blocks, center
    'align_vertical_center_rounded':
        0xf559, // [round] editor — align, alignment, arrangement, blocks, center
    'align_vertical_center_sharp':
        0xe77a, // [sharp] editor — align, alignment, arrangement, blocks, center
    'align_vertical_top':
        0xe07c, // editor — adjust, align, alignment, arrange, bar
    'align_vertical_top_outlined':
        0xee6d, // [outline] editor — adjust, align, alignment, arrange, bar
    'align_vertical_top_rounded':
        0xf55a, // [round] editor — adjust, align, alignment, arrange, bar
    'align_vertical_top_sharp':
        0xe77b, // [sharp] editor — adjust, align, alignment, arrange, bar
    'all_inbox': 0xe07d, // action — Inbox, all, all mail, archive, box
    'all_inbox_outlined':
        0xee6e, // [outline] action — Inbox, all, all mail, archive, box
    'all_inbox_rounded':
        0xf55b, // [round] action — Inbox, all, all mail, archive, box
    'all_inbox_sharp':
        0xe77c, // [sharp] action — Inbox, all, all mail, archive, box
    'all_inclusive':
        0xe07e, // places — abstract, all, boundless, complete, comprehensive
    'all_inclusive_outlined':
        0xee6f, // [outline] places — abstract, all, boundless, complete, comprehensive
    'all_inclusive_rounded':
        0xf55c, // [round] places — abstract, all, boundless, complete, comprehensive
    'all_inclusive_sharp':
        0xe77d, // [sharp] places — abstract, all, boundless, complete, comprehensive
    'all_out':
        0xe07f, // action — abstract, all, arrows, aspect ratio, bounding box
    'all_out_outlined':
        0xee70, // [outline] action — abstract, all, arrows, aspect ratio, bounding box
    'all_out_rounded':
        0xf55d, // [round] action — abstract, all, arrows, aspect ratio, bounding box
    'all_out_sharp':
        0xe77e, // [sharp] action — abstract, all, arrows, aspect ratio, bounding box
    'alt_route':
        0xe080, // maps — alt, alternate, alternate routes, alternative, arrows
    'alt_route_outlined':
        0xee71, // [outline] maps — alt, alternate, alternate routes, alternative, arrows
    'alt_route_rounded':
        0xf55e, // [round] maps — alt, alternate, alternate routes, alternative, arrows
    'alt_route_sharp':
        0xe77f, // [sharp] maps — alt, alternate, alternate routes, alternative, arrows
    'alternate_email':
        0xe081, // communication — @, address, address book, alternate, alternate contact
    'alternate_email_outlined':
        0xee72, // [outline] communication — @, address, address book, alternate, alternate contact
    'alternate_email_rounded':
        0xf55f, // [round] communication — @, address, address book, alternate, alternate contact
    'alternate_email_sharp':
        0xe780, // [sharp] communication — @, address, address book, alternate, alternate contact
    'amp_stories': 0xe082, // Text — amp, articles, bars, content, display
    'amp_stories_outlined':
        0xee73, // [outline] Text — amp, articles, bars, content, display
    'amp_stories_rounded':
        0xf560, // [round] Text — amp, articles, bars, content, display
    'amp_stories_sharp':
        0xe781, // [sharp] Text — amp, articles, bars, content, display
    'analytics':
        0xe083, // action — analysis, analytics, assessment, bar, bar chart
    'analytics_outlined':
        0xee74, // [outline] action — analysis, analytics, assessment, bar, bar chart
    'analytics_rounded':
        0xf561, // [round] action — analysis, analytics, assessment, bar, bar chart
    'analytics_sharp':
        0xe782, // [sharp] action — analysis, analytics, assessment, bar, bar chart
    'anchor': 0xe084, // action — anchor, attachment, base, boat, chain
    'anchor_outlined':
        0xee75, // [outline] action — anchor, attachment, base, boat, chain
    'anchor_rounded':
        0xf562, // [round] action — anchor, attachment, base, boat, chain
    'anchor_sharp':
        0xe783, // [sharp] action — anchor, attachment, base, boat, chain
    'android': 0xe085, // action — alien, android, antenna, brand, bugdroid
    'android_outlined':
        0xee76, // [outline] action — alien, android, antenna, brand, bugdroid
    'android_rounded':
        0xf563, // [round] action — alien, android, antenna, brand, bugdroid
    'android_sharp':
        0xe784, // [sharp] action — alien, android, antenna, brand, bugdroid
    'animation':
        0xe086, // image — active, activity, activity indicator, animation, busy
    'animation_outlined':
        0xee77, // [outline] image — active, activity, activity indicator, animation, busy
    'animation_rounded':
        0xf564, // [round] image — active, activity, activity indicator, animation, busy
    'animation_sharp':
        0xe785, // [sharp] image — active, activity, activity indicator, animation, busy
    'announcement':
        0xe087, // action — !, alert, announcement, attention, broadcast
    'announcement_outlined':
        0xee78, // [outline] action — !, alert, announcement, attention, broadcast
    'announcement_rounded':
        0xf565, // [round] action — !, alert, announcement, attention, broadcast
    'announcement_sharp':
        0xe786, // [sharp] action — !, alert, announcement, attention, broadcast
    'aod': 0xe088, // device — Android, OS, abstract, alert, always
    'aod_outlined':
        0xee79, // [outline] device — Android, OS, abstract, alert, always
    'aod_rounded':
        0xf566, // [round] device — Android, OS, abstract, alert, always
    'aod_sharp':
        0xe787, // [sharp] device — Android, OS, abstract, alert, always
    'apartment':
        0xe089, // places — accommodation, address, apartment, architecture, area
    'apartment_outlined':
        0xee7a, // [outline] places — accommodation, address, apartment, architecture, area
    'apartment_rounded':
        0xf567, // [round] places — accommodation, address, apartment, architecture, area
    'apartment_sharp':
        0xe788, // [sharp] places — accommodation, address, apartment, architecture, area
    'api': 0xe08a, // action — access, api, backend, bridge, cloud
    'api_outlined':
        0xee7b, // [outline] action — access, api, backend, bridge, cloud
    'api_rounded':
        0xf568, // [round] action — access, api, backend, bridge, cloud
    'api_sharp': 0xe789, // [sharp] action — access, api, backend, bridge, cloud
    'app_blocking':
        0xe08b, // action — Android, OS, access denied, app blocking, ban
    'app_blocking_outlined':
        0xee7c, // [outline] action — Android, OS, access denied, app blocking, ban
    'app_blocking_rounded':
        0xf569, // [round] action — Android, OS, access denied, app blocking, ban
    'app_blocking_sharp':
        0xe78a, // [sharp] action — Android, OS, access denied, app blocking, ban
    'app_registration':
        0xe08c, // communication — app registration, create account, data entry, details, documentation
    'app_registration_outlined':
        0xee7d, // [outline] communication — app registration, create account, data entry, details, documentation
    'app_registration_rounded':
        0xf56a, // [round] communication — app registration, create account, data entry, details, documentation
    'app_registration_sharp':
        0xe78b, // [sharp] communication — app registration, create account, data entry, details, documentation
    'app_settings_alt':
        0xe08d, // navigation — Android, OS, adjust, administration, applications
    'app_settings_alt_outlined':
        0xee7e, // [outline] navigation — Android, OS, adjust, administration, applications
    'app_settings_alt_rounded':
        0xf56b, // [round] navigation — Android, OS, adjust, administration, applications
    'app_settings_alt_sharp':
        0xe78c, // [sharp] navigation — Android, OS, adjust, administration, applications
    'app_shortcut': 0xf04bd, // action — Android, OS, access, broadcast, cast
    'app_shortcut_outlined':
        0xf05b8, // [outline] action — Android, OS, access, broadcast, cast
    'app_shortcut_rounded':
        0xf02d7, // [round] action — Android, OS, access, broadcast, cast
    'app_shortcut_sharp':
        0xf03ca, // [sharp] action — Android, OS, access, broadcast, cast
    'apple': 0xf04be, // brand logo
    'apple_outlined': 0xf05b9, // [outline] brand logo
    'apple_rounded': 0xf02d8, // [round] brand logo
    'apple_sharp': 0xf03cb, // [sharp] brand logo
    'approval':
        0xe08e, // file — accept, accepted, acknowledge, affirmative, agree
    'approval_outlined':
        0xee7f, // [outline] file — accept, accepted, acknowledge, affirmative, agree
    'approval_rounded':
        0xf56c, // [round] file — accept, accepted, acknowledge, affirmative, agree
    'approval_sharp':
        0xe78d, // [sharp] file — accept, accepted, acknowledge, affirmative, agree
    'apps':
        0xe08f, // navigation — 3x3 grid, access, all, all apps, applications
    'apps_outage':
        0xf04bf, // navigation — alert, all, applications, breakdown, circles
    'apps_outage_outlined':
        0xf05ba, // [outline] navigation — alert, all, applications, breakdown, circles
    'apps_outage_rounded':
        0xf02d9, // [round] navigation — alert, all, applications, breakdown, circles
    'apps_outage_sharp':
        0xf03cc, // [sharp] navigation — alert, all, applications, breakdown, circles
    'apps_outlined':
        0xee80, // [outline] navigation — 3x3 grid, access, all, all apps, applications
    'apps_rounded':
        0xf56d, // [round] navigation — 3x3 grid, access, all, all apps, applications
    'apps_sharp':
        0xe78e, // [sharp] navigation — 3x3 grid, access, all, all apps, applications
    'architecture':
        0xe090, // social — architecture, art, blueprint, building, city
    'architecture_outlined':
        0xee81, // [outline] social — architecture, art, blueprint, building, city
    'architecture_rounded':
        0xf56e, // [round] social — architecture, art, blueprint, building, city
    'architecture_sharp':
        0xe78f, // [sharp] social — architecture, art, blueprint, building, city
    'archive': 0xe091, // content — archive, archive box, backup, bin, box
    'archive_outlined':
        0xee82, // [outline] content — archive, archive box, backup, bin, box
    'archive_rounded':
        0xf56f, // [round] content — archive, archive box, backup, bin, box
    'archive_sharp':
        0xe790, // [sharp] content — archive, archive box, backup, bin, box
    'area_chart':
        0xf04c0, // editor — analysis, analytics, area, area chart, area filled
    'area_chart_outlined':
        0xf05bb, // [outline] editor — analysis, analytics, area, area chart, area filled
    'area_chart_rounded':
        0xf02da, // [round] editor — analysis, analytics, area, area chart, area filled
    'area_chart_sharp':
        0xf03cd, // [sharp] editor — analysis, analytics, area, area chart, area filled
    'arrow_back':
        0xe092, // navigation — arrow, back, back button, backward, chevron
    'arrow_back_ios':
        0xe093, // navigation — arrow, back, back arrow, backward, breadcrumb
    'arrow_back_ios_new':
        0xe094, // navigation — angle, arrow, back, back button, backward
    'arrow_back_ios_new_outlined':
        0xee83, // [outline] navigation — angle, arrow, back, back button, backward
    'arrow_back_ios_new_rounded':
        0xf570, // [round] navigation — angle, arrow, back, back button, backward
    'arrow_back_ios_new_sharp':
        0xe791, // [sharp] navigation — angle, arrow, back, back button, backward
    'arrow_back_ios_outlined':
        0xee84, // [outline] navigation — arrow, back, back arrow, backward, breadcrumb
    'arrow_back_ios_rounded':
        0xf571, // [round] navigation — arrow, back, back arrow, backward, breadcrumb
    'arrow_back_ios_sharp':
        0xe792, // [sharp] navigation — arrow, back, back arrow, backward, breadcrumb
    'arrow_back_outlined':
        0xee85, // [outline] navigation — arrow, back, back button, backward, chevron
    'arrow_back_rounded':
        0xf572, // [round] navigation — arrow, back, back button, backward, chevron
    'arrow_back_sharp':
        0xe793, // [sharp] navigation — arrow, back, back button, backward, chevron
    'arrow_circle_down':
        0xe095, // action — arrow, circle, collapse, contained, cursor
    'arrow_circle_down_outlined':
        0xee86, // [outline] action — arrow, circle, collapse, contained, cursor
    'arrow_circle_down_rounded':
        0xf573, // [round] action — arrow, circle, collapse, contained, cursor
    'arrow_circle_down_sharp':
        0xe794, // [sharp] action — arrow, circle, collapse, contained, cursor
    'arrow_circle_left':
        0xf04c1, // action — arrow, back, circle, circle arrow, circular
    'arrow_circle_left_outlined':
        0xf05bc, // [outline] action — arrow, back, circle, circle arrow, circular
    'arrow_circle_left_rounded':
        0xf02db, // [round] action — arrow, back, circle, circle arrow, circular
    'arrow_circle_left_sharp':
        0xf03ce, // [sharp] action — arrow, back, circle, circle arrow, circular
    'arrow_circle_right':
        0xf04c2, // action — arrow, arrow in circle, circle, circular arrow, continue
    'arrow_circle_right_outlined':
        0xf05bd, // [outline] action — arrow, arrow in circle, circle, circular arrow, continue
    'arrow_circle_right_rounded':
        0xf02dc, // [round] action — arrow, arrow in circle, circle, circular arrow, continue
    'arrow_circle_right_sharp':
        0xf03cf, // [sharp] action — arrow, arrow in circle, circle, circular arrow, continue
    'arrow_circle_up':
        0xe096, // action — arrow, circle, circular arrow, data transfer, direction
    'arrow_circle_up_outlined':
        0xee87, // [outline] action — arrow, circle, circular arrow, data transfer, direction
    'arrow_circle_up_rounded':
        0xf574, // [round] action — arrow, circle, circular arrow, data transfer, direction
    'arrow_circle_up_sharp':
        0xe795, // [sharp] action — arrow, circle, circular arrow, data transfer, direction
    'arrow_downward':
        0xe097, // navigation — arrow, collapse, continue, descending, direction
    'arrow_downward_outlined':
        0xee88, // [outline] navigation — arrow, collapse, continue, descending, direction
    'arrow_downward_rounded':
        0xf575, // [round] navigation — arrow, collapse, continue, descending, direction
    'arrow_downward_sharp':
        0xe796, // [sharp] navigation — arrow, collapse, continue, descending, direction
    'arrow_drop_down':
        0xe098, // navigation — arrow, carat, caret, chevron, collapse
    'arrow_drop_down_circle':
        0xe099, // navigation — arrow, choose, circle, circled arrow, circled down arrow
    'arrow_drop_down_circle_outlined':
        0xee89, // [outline] navigation — arrow, choose, circle, circled arrow, circled down arrow
    'arrow_drop_down_circle_rounded':
        0xf576, // [round] navigation — arrow, choose, circle, circled arrow, circled down arrow
    'arrow_drop_down_circle_sharp':
        0xe797, // [sharp] navigation — arrow, choose, circle, circled arrow, circled down arrow
    'arrow_drop_down_outlined':
        0xee8a, // [outline] navigation — arrow, carat, caret, chevron, collapse
    'arrow_drop_down_rounded':
        0xf577, // [round] navigation — arrow, carat, caret, chevron, collapse
    'arrow_drop_down_sharp':
        0xe798, // [sharp] navigation — arrow, carat, caret, chevron, collapse
    'arrow_drop_up':
        0xe09a, // navigation — arrow, caret, caret up, collapse, collapse button
    'arrow_drop_up_outlined':
        0xee8b, // [outline] navigation — arrow, caret, caret up, collapse, collapse button
    'arrow_drop_up_rounded':
        0xf578, // [round] navigation — arrow, caret, caret up, collapse, collapse button
    'arrow_drop_up_sharp':
        0xe799, // [sharp] navigation — arrow, caret, caret up, collapse, collapse button
    'arrow_forward':
        0xe09b, // navigation — advance, arrow, arrows, continue, direction
    'arrow_forward_ios':
        0xe09c, // navigation — advance, angle, arrow, caret, chevron
    'arrow_forward_ios_outlined':
        0xee8c, // [outline] navigation — advance, angle, arrow, caret, chevron
    'arrow_forward_ios_rounded':
        0xf579, // [round] navigation — advance, angle, arrow, caret, chevron
    'arrow_forward_ios_sharp':
        0xe79a, // [sharp] navigation — advance, angle, arrow, caret, chevron
    'arrow_forward_outlined':
        0xee8d, // [outline] navigation — advance, arrow, arrows, continue, direction
    'arrow_forward_rounded':
        0xf57a, // [round] navigation — advance, arrow, arrows, continue, direction
    'arrow_forward_sharp':
        0xe79b, // [sharp] navigation — advance, arrow, arrows, continue, direction
    'arrow_left': 0xe09d, // navigation — angle, arrow, back, backward, curve
    'arrow_left_outlined':
        0xee8e, // [outline] navigation — angle, arrow, back, backward, curve
    'arrow_left_rounded':
        0xf57b, // [round] navigation — angle, arrow, back, backward, curve
    'arrow_left_sharp':
        0xe79c, // [sharp] navigation — angle, arrow, back, backward, curve
    'arrow_outward':
        0xf0852, // action — access, arrow, arrows, connection, diagonal
    'arrow_outward_outlined':
        0xf089b, // [outline] action — access, arrow, arrows, connection, diagonal
    'arrow_outward_rounded':
        0xf087d, // [round] action — access, arrow, arrows, connection, diagonal
    'arrow_outward_sharp':
        0xf0834, // [sharp] action — access, arrow, arrows, connection, diagonal
    'arrow_right': 0xe09e, // navigation — advance, angle, arrow, caret, chevron
    'arrow_right_alt':
        0xe09f, // action — access, alt, arrow, arrow symbol, arrows
    'arrow_right_alt_outlined':
        0xee8f, // [outline] action — access, alt, arrow, arrow symbol, arrows
    'arrow_right_alt_rounded':
        0xf57c, // [round] action — access, alt, arrow, arrow symbol, arrows
    'arrow_right_alt_sharp':
        0xe79d, // [sharp] action — access, alt, arrow, arrow symbol, arrows
    'arrow_right_outlined':
        0xee90, // [outline] navigation — advance, angle, arrow, caret, chevron
    'arrow_right_rounded':
        0xf57d, // [round] navigation — advance, angle, arrow, caret, chevron
    'arrow_right_sharp':
        0xe79e, // [sharp] navigation — advance, angle, arrow, caret, chevron
    'arrow_upward':
        0xe0a0, // navigation — above, arrow, ascend, direction, elevate
    'arrow_upward_outlined':
        0xee91, // [outline] navigation — above, arrow, ascend, direction, elevate
    'arrow_upward_rounded':
        0xf57e, // [round] navigation — above, arrow, ascend, direction, elevate
    'arrow_upward_sharp':
        0xe79f, // [sharp] navigation — above, arrow, ascend, direction, elevate
    'art_track': 0xe0a1, // av — album, album art, art, artist, audio
    'art_track_outlined':
        0xee92, // [outline] av — album, album art, art, artist, audio
    'art_track_rounded':
        0xf57f, // [round] av — album, album art, art, artist, audio
    'art_track_sharp':
        0xe7a0, // [sharp] av — album, album art, art, artist, audio
    'article': 0xe0a2, // action — article, blog, content, description, doc
    'article_outlined':
        0xee93, // [outline] action — article, blog, content, description, doc
    'article_rounded':
        0xf580, // [round] action — article, blog, content, description, doc
    'article_sharp':
        0xe7a1, // [sharp] action — article, blog, content, description, doc
    'aspect_ratio':
        0xe0a3, // action — adjust, aspect, aspect ratio, crop, custom
    'aspect_ratio_outlined':
        0xee94, // [outline] action — adjust, aspect, aspect ratio, crop, custom
    'aspect_ratio_rounded':
        0xf581, // [round] action — adjust, aspect, aspect ratio, crop, custom
    'aspect_ratio_sharp':
        0xe7a2, // [sharp] action — adjust, aspect, aspect ratio, crop, custom
    'assessment':
        0xe0a4, // action — analysis, analytics, assessment, bar, bar chart
    'assessment_outlined':
        0xee95, // [outline] action — analysis, analytics, assessment, bar, bar chart
    'assessment_rounded':
        0xf582, // [round] action — analysis, analytics, assessment, bar, bar chart
    'assessment_sharp':
        0xe7a3, // [sharp] action — analysis, analytics, assessment, bar, bar chart
    'assignment':
        0xe0a5, // action — agenda, assignment, checklist, class, clipboard
    'assignment_add':
        0xf0853, // action — +, add, add assignment, add document, add task
    'assignment_ind':
        0xe0a6, // action — account, apply, assignment, badge, card
    'assignment_ind_outlined':
        0xee96, // [outline] action — account, apply, assignment, badge, card
    'assignment_ind_rounded':
        0xf583, // [round] action — account, apply, assignment, badge, card
    'assignment_ind_sharp':
        0xe7a4, // [sharp] action — account, apply, assignment, badge, card
    'assignment_late':
        0xe0a7, // action — !, alert, assignment, assignment late, attention
    'assignment_late_outlined':
        0xee97, // [outline] action — !, alert, assignment, assignment late, attention
    'assignment_late_rounded':
        0xf584, // [round] action — !, alert, assignment, assignment late, attention
    'assignment_late_sharp':
        0xe7a5, // [sharp] action — !, alert, assignment, assignment late, attention
    'assignment_outlined':
        0xee98, // [outline] action — agenda, assignment, checklist, class, clipboard
    'assignment_return':
        0xe0a8, // action — approval, arrow, assignment, back, checklist
    'assignment_return_outlined':
        0xee99, // [outline] action — approval, arrow, assignment, back, checklist
    'assignment_return_rounded':
        0xf585, // [round] action — approval, arrow, assignment, back, checklist
    'assignment_return_sharp':
        0xe7a6, // [sharp] action — approval, arrow, assignment, back, checklist
    'assignment_returned':
        0xe0a9, // action — arrow, assignment, assignment returned, business, checking
    'assignment_returned_outlined':
        0xee9a, // [outline] action — arrow, assignment, assignment returned, business, checking
    'assignment_returned_rounded':
        0xf586, // [round] action — arrow, assignment, assignment returned, business, checking
    'assignment_returned_sharp':
        0xe7a7, // [sharp] action — arrow, assignment, assignment returned, business, checking
    'assignment_rounded':
        0xf587, // [round] action — agenda, assignment, checklist, class, clipboard
    'assignment_sharp':
        0xe7a8, // [sharp] action — agenda, assignment, checklist, class, clipboard
    'assignment_turned_in':
        0xe0aa, // action — accepted, approve, approved, assignment, box
    'assignment_turned_in_outlined':
        0xee9b, // [outline] action — accepted, approve, approved, assignment, box
    'assignment_turned_in_rounded':
        0xf588, // [round] action — accepted, approve, approved, assignment, box
    'assignment_turned_in_sharp':
        0xe7a9, // [sharp] action — accepted, approve, approved, assignment, box
    'assist_walker':
        0xf0854, // social — accessibility, accessible, aid, assist, assistance
    'assist_walker_outlined':
        0xf089c, // [outline] social — accessibility, accessible, aid, assist, assistance
    'assist_walker_rounded':
        0xf087e, // [round] social — accessibility, accessible, aid, assist, assistance
    'assist_walker_sharp':
        0xf0835, // [sharp] social — accessibility, accessible, aid, assist, assistance
    'assistant':
        0xe0ab, // image — ai, answer, artificial, assistant, assistant bubble
    'assistant_direction':
        0xe0ac, // navigation — advising, angled arrow, arrow, assistant, destination
    'assistant_direction_outlined':
        0xee9c, // [outline] navigation — advising, angled arrow, arrow, assistant, destination
    'assistant_direction_rounded':
        0xf589, // [round] navigation — advising, angled arrow, arrow, assistant, destination
    'assistant_direction_sharp':
        0xe7aa, // [sharp] navigation — advising, angled arrow, arrow, assistant, destination
    'assistant_navigation':
        0xe0ad, // navigation — ai, arrow, assistant, assistant navigation, chatbot
    'assistant_outlined':
        0xee9d, // [outline] image — ai, answer, artificial, assistant, assistant bubble
    'assistant_photo':
        0xe0ae, // image — achievement, assistant, banner, bookmark, country
    'assistant_photo_outlined':
        0xee9e, // [outline] image — achievement, assistant, banner, bookmark, country
    'assistant_photo_rounded':
        0xf58a, // [round] image — achievement, assistant, banner, bookmark, country
    'assistant_photo_sharp':
        0xe7ab, // [sharp] image — achievement, assistant, banner, bookmark, country
    'assistant_rounded':
        0xf58b, // [round] image — ai, answer, artificial, assistant, assistant bubble
    'assistant_sharp':
        0xe7ac, // [sharp] image — ai, answer, artificial, assistant, assistant bubble
    'assured_workload':
        0xf04c3, // action — account, activity, approved, assignment, assurance
    'assured_workload_outlined':
        0xf05be, // [outline] action — account, activity, approved, assignment, assurance
    'assured_workload_rounded':
        0xf02dd, // [round] action — account, activity, approved, assignment, assurance
    'assured_workload_sharp':
        0xf03d0, // [sharp] action — account, activity, approved, assignment, assurance
    'atm': 0xe0af, // maps — alphabet, atm, automated, banking, bill
    'atm_outlined':
        0xee9f, // [outline] maps — alphabet, atm, automated, banking, bill
    'atm_rounded':
        0xf58c, // [round] maps — alphabet, atm, automated, banking, bill
    'atm_sharp':
        0xe7ad, // [sharp] maps — alphabet, atm, automated, banking, bill
    'attach_email':
        0xe0b0, // file — add, add attachment, add file, attach, attach file
    'attach_email_outlined':
        0xeea0, // [outline] file — add, add attachment, add file, attach, attach file
    'attach_email_rounded':
        0xf58d, // [round] file — add, add attachment, add file, attach, attach file
    'attach_email_sharp':
        0xe7ae, // [sharp] file — add, add attachment, add file, attach, attach file
    'attach_file': 0xe0b1, // editor — add, append, attach, attachment, binding
    'attach_file_outlined':
        0xeea1, // [outline] editor — add, append, attach, attachment, binding
    'attach_file_rounded':
        0xf58e, // [round] editor — add, append, attach, attachment, binding
    'attach_file_sharp':
        0xe7af, // [sharp] editor — add, append, attach, attachment, binding
    'attach_money': 0xe0b2, // editor — add money, amount, attach, banking, bill
    'attach_money_outlined':
        0xeea2, // [outline] editor — add money, amount, attach, banking, bill
    'attach_money_rounded':
        0xf58f, // [round] editor — add money, amount, attach, banking, bill
    'attach_money_sharp':
        0xe7b0, // [sharp] editor — add money, amount, attach, banking, bill
    'attachment':
        0xe0b3, // file — add file, attach, attachment, clip, communication
    'attachment_outlined':
        0xeea3, // [outline] file — add file, attach, attachment, clip, communication
    'attachment_rounded':
        0xf590, // [round] file — add file, attach, attachment, clip, communication
    'attachment_sharp':
        0xe7b1, // [sharp] file — add file, attach, attachment, clip, communication
    'attractions':
        0xe0b4, // maps — Ferris wheel, activity, amusement, amusement park, attractions
    'attractions_outlined':
        0xeea4, // [outline] maps — Ferris wheel, activity, amusement, amusement park, attractions
    'attractions_rounded':
        0xf591, // [round] maps — Ferris wheel, activity, amusement, amusement park, attractions
    'attractions_sharp':
        0xe7b2, // [sharp] maps — Ferris wheel, activity, amusement, amusement park, attractions
    'attribution':
        0xe0b5, // content — account, attribute, attribution, author, body
    'attribution_outlined':
        0xeea5, // [outline] content — account, attribute, attribution, author, body
    'attribution_rounded':
        0xf592, // [round] content — account, attribute, attribution, author, body
    'attribution_sharp':
        0xe7b3, // [sharp] content — account, attribute, attribution, author, body
    'audio_file': 0xf04c4, // av — add, audio, bars, chart, create
    'audio_file_outlined':
        0xf05bf, // [outline] av — add, audio, bars, chart, create
    'audio_file_rounded':
        0xf02de, // [round] av — add, audio, bars, chart, create
    'audio_file_sharp': 0xf03d1, // [sharp] av — add, audio, bars, chart, create
    'audiotrack':
        0xe0b6, // image — audio, audio file, audiotrack, clef, composition
    'audiotrack_outlined':
        0xeea6, // [outline] image — audio, audio file, audiotrack, clef, composition
    'audiotrack_rounded':
        0xf593, // [round] image — audio, audio file, audiotrack, clef, composition
    'audiotrack_sharp':
        0xe7b4, // [sharp] image — audio, audio file, audiotrack, clef, composition
    'auto_awesome': 0xe0b7, // image — adjust, ai, artificial, auto, automatic
    'auto_awesome_mosaic': 0xe0b8, // image — adjust, album, arrange, art, auto
    'auto_awesome_mosaic_outlined':
        0xeea7, // [outline] image — adjust, album, arrange, art, auto
    'auto_awesome_mosaic_rounded':
        0xf594, // [round] image — adjust, album, arrange, art, auto
    'auto_awesome_mosaic_sharp':
        0xe7b5, // [sharp] image — adjust, album, arrange, art, auto
    'auto_awesome_motion':
        0xe0b9, // image — AI, adjust, animate, animation, auto
    'auto_awesome_motion_outlined':
        0xeea8, // [outline] image — AI, adjust, animate, animation, auto
    'auto_awesome_motion_rounded':
        0xf595, // [round] image — AI, adjust, animate, animation, auto
    'auto_awesome_motion_sharp':
        0xe7b6, // [sharp] image — AI, adjust, animate, animation, auto
    'auto_awesome_outlined':
        0xeea9, // [outline] image — adjust, ai, artificial, auto, automatic
    'auto_awesome_rounded':
        0xf596, // [round] image — adjust, ai, artificial, auto, automatic
    'auto_awesome_sharp':
        0xe7b7, // [sharp] image — adjust, ai, artificial, auto, automatic
    'auto_delete': 0xe0ba, // alert — archive, auto, auto delete, automatic, bin
    'auto_delete_outlined':
        0xeeaa, // [outline] alert — archive, auto, auto delete, automatic, bin
    'auto_delete_rounded':
        0xf597, // [round] alert — archive, auto, auto delete, automatic, bin
    'auto_delete_sharp':
        0xe7b8, // [sharp] alert — archive, auto, auto delete, automatic, bin
    'auto_fix_high': 0xe0bb, // image — adjust, ai, artificial, auto, automated
    'auto_fix_high_outlined':
        0xeeab, // [outline] image — adjust, ai, artificial, auto, automated
    'auto_fix_high_rounded':
        0xf598, // [round] image — adjust, ai, artificial, auto, automated
    'auto_fix_high_sharp':
        0xe7b9, // [sharp] image — adjust, ai, artificial, auto, automated
    'auto_fix_normal': 0xe0bc, // image — adjust, ai, apply, artificial, auto
    'auto_fix_normal_outlined':
        0xeeac, // [outline] image — adjust, ai, apply, artificial, auto
    'auto_fix_normal_rounded':
        0xf599, // [round] image — adjust, ai, apply, artificial, auto
    'auto_fix_normal_sharp':
        0xe7ba, // [sharp] image — adjust, ai, apply, artificial, auto
    'auto_fix_off':
        0xe0bd, // image — adjustments off, ai, artificial, auto, auto enhance off
    'auto_fix_off_outlined':
        0xeead, // [outline] image — adjustments off, ai, artificial, auto, auto enhance off
    'auto_fix_off_rounded':
        0xf59a, // [round] image — adjustments off, ai, artificial, auto, auto enhance off
    'auto_fix_off_sharp':
        0xe7bb, // [sharp] image — adjustments off, ai, artificial, auto, auto enhance off
    'auto_graph':
        0xe0be, // editor — analysis, analytics, auto, auto graph, automated
    'auto_graph_outlined':
        0xeeae, // [outline] editor — analysis, analytics, auto, auto graph, automated
    'auto_graph_rounded':
        0xf59b, // [round] editor — analysis, analytics, auto, auto graph, automated
    'auto_graph_sharp':
        0xe7bc, // [sharp] editor — analysis, analytics, auto, auto graph, automated
    'auto_mode': 0xf0787, // home — a, ai, alphabet, around, arrow
    'auto_mode_outlined':
        0xf06d7, // [outline] home — a, ai, alphabet, around, arrow
    'auto_mode_rounded':
        0xf07df, // [round] home — a, ai, alphabet, around, arrow
    'auto_mode_sharp': 0xf072f, // [sharp] home — a, ai, alphabet, around, arrow
    'auto_stories':
        0xe0bf, // image — archive, articles, auto, bibliography, book
    'auto_stories_outlined':
        0xeeaf, // [outline] image — archive, articles, auto, bibliography, book
    'auto_stories_rounded':
        0xf59c, // [round] image — archive, articles, auto, bibliography, book
    'auto_stories_sharp':
        0xe7bd, // [sharp] image — archive, articles, auto, bibliography, book
    'autofps_select': 0xe0c0, // image — A, adjust, alphabet, animation, auto
    'autofps_select_outlined':
        0xeeb0, // [outline] image — A, adjust, alphabet, animation, auto
    'autofps_select_rounded':
        0xf59d, // [round] image — A, adjust, alphabet, animation, auto
    'autofps_select_sharp':
        0xe7be, // [sharp] image — A, adjust, alphabet, animation, auto
    'autorenew': 0xe0c1, // action — around, arrow, arrows, autorenew, cache
    'autorenew_outlined':
        0xeeb1, // [outline] action — around, arrow, arrows, autorenew, cache
    'autorenew_rounded':
        0xf59e, // [round] action — around, arrow, arrows, autorenew, cache
    'autorenew_sharp':
        0xe7bf, // [sharp] action — around, arrow, arrows, autorenew, cache
    'av_timer': 0xe0c2, // av — alert, av, chronograph, circular, clock
    'av_timer_outlined':
        0xeeb2, // [outline] av — alert, av, chronograph, circular, clock
    'av_timer_rounded':
        0xf59f, // [round] av — alert, av, chronograph, circular, clock
    'av_timer_sharp':
        0xe7c0, // [sharp] av — alert, av, chronograph, circular, clock
    'baby_changing_station':
        0xe0c3, // places — accessibility, amenities, babies, baby, bathroom
    'baby_changing_station_outlined':
        0xeeb3, // [outline] places — accessibility, amenities, babies, baby, bathroom
    'baby_changing_station_rounded':
        0xf5a0, // [round] places — accessibility, amenities, babies, baby, bathroom
    'baby_changing_station_sharp':
        0xe7c1, // [sharp] places — accessibility, amenities, babies, baby, bathroom
    'back_hand':
        0xf04c5, // social — anatomy, appendage, back, back of hand, backhand
    'back_hand_outlined':
        0xf05c0, // [outline] social — anatomy, appendage, back, back of hand, backhand
    'back_hand_rounded':
        0xf02df, // [round] social — anatomy, appendage, back, back of hand, backhand
    'back_hand_sharp':
        0xf03d2, // [sharp] social — anatomy, appendage, back, back of hand, backhand
    'backpack': 0xe0c4, // places — adventure, back, backpack, bag, book
    'backpack_outlined':
        0xeeb4, // [outline] places — adventure, back, backpack, bag, book
    'backpack_rounded':
        0xf5a1, // [round] places — adventure, back, backpack, bag, book
    'backpack_sharp':
        0xe7c2, // [sharp] places — adventure, back, backpack, bag, book
    'backspace': 0xe0c5, // content — arrow, back, backspace, box, cancel
    'backspace_outlined':
        0xeeb5, // [outline] content — arrow, back, backspace, box, cancel
    'backspace_rounded':
        0xf5a2, // [round] content — arrow, back, backspace, box, cancel
    'backspace_sharp':
        0xe7c3, // [sharp] content — arrow, back, backspace, box, cancel
    'backup': 0xe0c6, // action — archive, arrow, backup, cloud, computing
    'backup_outlined':
        0xeeb6, // [outline] action — archive, arrow, backup, cloud, computing
    'backup_rounded':
        0xf5a3, // [round] action — archive, arrow, backup, cloud, computing
    'backup_sharp':
        0xe7c4, // [sharp] action — archive, arrow, backup, cloud, computing
    'backup_table': 0xe0c7, // action — archive, backup, cloud, columns, copy
    'backup_table_outlined':
        0xeeb7, // [outline] action — archive, backup, cloud, columns, copy
    'backup_table_rounded':
        0xf5a4, // [round] action — archive, backup, cloud, columns, copy
    'backup_table_sharp':
        0xe7c5, // [sharp] action — archive, backup, cloud, columns, copy
    'badge': 0xe0c8, // maps — accolade, account, achievement, approval, avatar
    'badge_outlined':
        0xeeb8, // [outline] maps — accolade, account, achievement, approval, avatar
    'badge_rounded':
        0xf5a5, // [round] maps — accolade, account, achievement, approval, avatar
    'badge_sharp':
        0xe7c6, // [sharp] maps — accolade, account, achievement, approval, avatar
    'bakery_dining':
        0xe0c9, // maps — baked goods, bakery, baking, bread, breakfast
    'bakery_dining_outlined':
        0xeeb9, // [outline] maps — baked goods, bakery, baking, bread, breakfast
    'bakery_dining_rounded':
        0xf5a6, // [round] maps — baked goods, bakery, baking, bread, breakfast
    'bakery_dining_sharp':
        0xe7c7, // [sharp] maps — baked goods, bakery, baking, bread, breakfast
    'balance':
        0xf04c6, // action — balance, compare, compare and contrast, court, courthouse
    'balance_outlined':
        0xf05c1, // [outline] action — balance, compare, compare and contrast, court, courthouse
    'balance_rounded':
        0xf02e0, // [round] action — balance, compare, compare and contrast, court, courthouse
    'balance_sharp':
        0xf03d3, // [sharp] action — balance, compare, compare and contrast, court, courthouse
    'balcony':
        0xe0ca, // places — accommodation, apartment, architecture, balcony, building
    'balcony_outlined':
        0xeeba, // [outline] places — accommodation, apartment, architecture, balcony, building
    'balcony_rounded':
        0xf5a7, // [round] places — accommodation, apartment, architecture, balcony, building
    'balcony_sharp':
        0xe7c8, // [sharp] places — accommodation, apartment, architecture, balcony, building
    'ballot': 0xe0cb, // content — agreement, ballot, box, bullet, checklist
    'ballot_outlined':
        0xeebb, // [outline] content — agreement, ballot, box, bullet, checklist
    'ballot_rounded':
        0xf5a8, // [round] content — agreement, ballot, box, bullet, checklist
    'ballot_sharp':
        0xe7c9, // [sharp] content — agreement, ballot, box, bullet, checklist
    'bar_chart': 0xe0cc, // editor — analysis, analytics, bar, bar chart, bars
    'bar_chart_outlined':
        0xeebc, // [outline] editor — analysis, analytics, bar, bar chart, bars
    'bar_chart_rounded':
        0xf5a9, // [round] editor — analysis, analytics, bar, bar chart, bars
    'bar_chart_sharp':
        0xe7ca, // [sharp] editor — analysis, analytics, bar, bar chart, bars
    'barcode_reader':
        0xf0855, // action — barcode, camera, capture, code, digital
    'batch_prediction':
        0xe0cd, // action — ai, algorithms, analysis, automated, batch
    'batch_prediction_outlined':
        0xeebd, // [outline] action — ai, algorithms, analysis, automated, batch
    'batch_prediction_rounded':
        0xf5aa, // [round] action — ai, algorithms, analysis, automated, batch
    'batch_prediction_sharp':
        0xe7cb, // [sharp] action — ai, algorithms, analysis, automated, batch
    'bathroom':
        0xe0ce, // search — accessibility, accessible, amenities, bar, bath
    'bathroom_outlined':
        0xeebe, // [outline] search — accessibility, accessible, amenities, bar, bath
    'bathroom_rounded':
        0xf5ab, // [round] search — accessibility, accessible, amenities, bar, bath
    'bathroom_sharp':
        0xe7cc, // [sharp] search — accessibility, accessible, amenities, bar, bath
    'bathtub': 0xe0cf, // places — amenity, appliance, bath, bathing, bathroom
    'bathtub_outlined':
        0xeebf, // [outline] places — amenity, appliance, bath, bathing, bathroom
    'bathtub_rounded':
        0xf5ac, // [round] places — amenity, appliance, bath, bathing, bathroom
    'bathtub_sharp':
        0xe7cd, // [sharp] places — amenity, appliance, bath, bathing, bathroom
    'battery_0_bar': 0xf0788, // device — alert, bar, battery, cell, charge
    'battery_0_bar_outlined':
        0xf06d8, // [outline] device — alert, bar, battery, cell, charge
    'battery_0_bar_rounded':
        0xf07e0, // [round] device — alert, bar, battery, cell, charge
    'battery_0_bar_sharp':
        0xf0730, // [sharp] device — alert, bar, battery, cell, charge
    'battery_1_bar': 0xf0789, // device — 1 bar, 20 percent, 20%, bar, battery
    'battery_1_bar_outlined':
        0xf06d9, // [outline] device — 1 bar, 20 percent, 20%, bar, battery
    'battery_1_bar_rounded':
        0xf07e1, // [round] device — 1 bar, 20 percent, 20%, bar, battery
    'battery_1_bar_sharp':
        0xf0731, // [sharp] device — 1 bar, 20 percent, 20%, bar, battery
    'battery_2_bar':
        0xf078a, // device — 2 bars, 30 percent, bar, battery, battery indicator
    'battery_2_bar_outlined':
        0xf06da, // [outline] device — 2 bars, 30 percent, bar, battery, battery indicator
    'battery_2_bar_rounded':
        0xf07e2, // [round] device — 2 bars, 30 percent, bar, battery, battery indicator
    'battery_2_bar_sharp':
        0xf0732, // [sharp] device — 2 bars, 30 percent, bar, battery, battery indicator
    'battery_3_bar':
        0xf078b, // device — 50%, bar, battery, battery gauge, battery indicator
    'battery_3_bar_outlined':
        0xf06db, // [outline] device — 50%, bar, battery, battery gauge, battery indicator
    'battery_3_bar_rounded':
        0xf07e3, // [round] device — 50%, bar, battery, battery gauge, battery indicator
    'battery_3_bar_sharp':
        0xf0733, // [sharp] device — 50%, bar, battery, battery gauge, battery indicator
    'battery_4_bar': 0xf078c, // device — 60, almost full, bar, bars, battery
    'battery_4_bar_outlined':
        0xf06dc, // [outline] device — 60, almost full, bar, bars, battery
    'battery_4_bar_rounded':
        0xf07e4, // [round] device — 60, almost full, bar, bars, battery
    'battery_4_bar_sharp':
        0xf0734, // [sharp] device — 60, almost full, bar, bars, battery
    'battery_5_bar': 0xf078d, // device — 80%, bars, battery, cell, charge
    'battery_5_bar_outlined':
        0xf06dd, // [outline] device — 80%, bars, battery, cell, charge
    'battery_5_bar_rounded':
        0xf07e5, // [round] device — 80%, bars, battery, cell, charge
    'battery_5_bar_sharp':
        0xf0735, // [sharp] device — 80%, bars, battery, cell, charge
    'battery_6_bar': 0xf078e, // device — 90, almost full, bar, bars, battery
    'battery_6_bar_outlined':
        0xf06de, // [outline] device — 90, almost full, bar, bars, battery
    'battery_6_bar_rounded':
        0xf07e6, // [round] device — 90, almost full, bar, bars, battery
    'battery_6_bar_sharp':
        0xf0736, // [sharp] device — 90, almost full, bar, bars, battery
    'battery_alert': 0xe0d0, // device — !, alert, attention, battery, caution
    'battery_alert_outlined':
        0xeec0, // [outline] device — !, alert, attention, battery, caution
    'battery_alert_rounded':
        0xf5ad, // [round] device — !, alert, attention, battery, caution
    'battery_alert_sharp':
        0xe7ce, // [sharp] device — !, alert, attention, battery, caution
    'battery_charging_full':
        0xe0d1, // device — battery, bolt, capacity, cell, charge
    'battery_charging_full_outlined':
        0xeec1, // [outline] device — battery, bolt, capacity, cell, charge
    'battery_charging_full_rounded':
        0xf5ae, // [round] device — battery, bolt, capacity, cell, charge
    'battery_charging_full_sharp':
        0xe7cf, // [sharp] device — battery, bolt, capacity, cell, charge
    'battery_full':
        0xe0d2, // device — bar, battery, battery level, battery meter, cell
    'battery_full_outlined':
        0xeec2, // [outline] device — bar, battery, battery level, battery meter, cell
    'battery_full_rounded':
        0xf5af, // [round] device — bar, battery, battery level, battery meter, cell
    'battery_full_sharp':
        0xe7d0, // [sharp] device — bar, battery, battery level, battery meter, cell
    'battery_saver': 0xe0d3, // device — +, add, addition, bar, battery
    'battery_saver_outlined':
        0xeec3, // [outline] device — +, add, addition, bar, battery
    'battery_saver_rounded':
        0xf5b0, // [round] device — +, add, addition, bar, battery
    'battery_saver_sharp':
        0xe7d1, // [sharp] device — +, add, addition, bar, battery
    'battery_std':
        0xe0d4, // device — bar, battery, battery level, battery meter, cell
    'battery_std_outlined':
        0xeec4, // [outline] device — bar, battery, battery level, battery meter, cell
    'battery_std_rounded':
        0xf5b1, // [round] device — bar, battery, battery level, battery meter, cell
    'battery_std_sharp':
        0xe7d2, // [sharp] device — bar, battery, battery level, battery meter, cell
    'battery_unknown': 0xe0d5, // device — ?, assistance, battery, cell, charge
    'battery_unknown_outlined':
        0xeec5, // [outline] device — ?, assistance, battery, cell, charge
    'battery_unknown_rounded':
        0xf5b2, // [round] device — ?, assistance, battery, cell, charge
    'battery_unknown_sharp':
        0xe7d3, // [sharp] device — ?, assistance, battery, cell, charge
    'beach_access':
        0xe0d6, // places — access, activity, beach, coastal, coastline
    'beach_access_outlined':
        0xeec6, // [outline] places — access, activity, beach, coastal, coastline
    'beach_access_rounded':
        0xf5b3, // [round] places — access, activity, beach, coastal, coastline
    'beach_access_sharp':
        0xe7d4, // [sharp] places — access, activity, beach, coastal, coastline
    'bed': 0xe0d7, // search — apartment, bed, bedroom, bedtime, blanket
    'bed_outlined':
        0xeec7, // [outline] search — apartment, bed, bedroom, bedtime, blanket
    'bed_rounded':
        0xf5b4, // [round] search — apartment, bed, bedroom, bedtime, blanket
    'bed_sharp':
        0xe7d5, // [sharp] search — apartment, bed, bedroom, bedtime, blanket
    'bedroom_baby': 0xe0d8, // search — babies, baby, bed, bedroom, care
    'bedroom_baby_outlined':
        0xeec8, // [outline] search — babies, baby, bed, bedroom, care
    'bedroom_baby_rounded':
        0xf5b5, // [round] search — babies, baby, bed, bedroom, care
    'bedroom_baby_sharp':
        0xe7d6, // [sharp] search — babies, baby, bed, bedroom, care
    'bedroom_child':
        0xe0d9, // search — accommodation, baby, bed, bedroom, building
    'bedroom_child_outlined':
        0xeec9, // [outline] search — accommodation, baby, bed, bedroom, building
    'bedroom_child_rounded':
        0xf5b6, // [round] search — accommodation, baby, bed, bedroom, building
    'bedroom_child_sharp':
        0xe7d7, // [sharp] search — accommodation, baby, bed, bedroom, building
    'bedroom_parent': 0xe0da, // search — adult, bed, bedroom, building, child
    'bedroom_parent_outlined':
        0xeeca, // [outline] search — adult, bed, bedroom, building, child
    'bedroom_parent_rounded':
        0xf5b7, // [round] search — adult, bed, bedroom, building, child
    'bedroom_parent_sharp':
        0xe7d8, // [sharp] search — adult, bed, bedroom, building, child
    'bedtime':
        0xe0db, // image — astronomy, bedtime, calm, celestial, celestial bodies
    'bedtime_off': 0xf04c7, // image — active, bedtime, clear, climate, crescent
    'bedtime_off_outlined':
        0xf05c2, // [outline] image — active, bedtime, clear, climate, crescent
    'bedtime_off_rounded':
        0xf02e1, // [round] image — active, bedtime, clear, climate, crescent
    'bedtime_off_sharp':
        0xf03d4, // [sharp] image — active, bedtime, clear, climate, crescent
    'bedtime_outlined':
        0xeecb, // [outline] image — astronomy, bedtime, calm, celestial, celestial bodies
    'bedtime_rounded':
        0xf5b8, // [round] image — astronomy, bedtime, calm, celestial, celestial bodies
    'bedtime_sharp':
        0xe7d9, // [sharp] image — astronomy, bedtime, calm, celestial, celestial bodies
    'beenhere':
        0xe0dc, // maps — acknowledgement, approve, archive, arrival, been
    'beenhere_outlined':
        0xeecc, // [outline] maps — acknowledgement, approve, archive, arrival, been
    'beenhere_rounded':
        0xf5b9, // [round] maps — acknowledgement, approve, archive, arrival, been
    'beenhere_sharp':
        0xe7da, // [sharp] maps — acknowledgement, approve, archive, arrival, been
    'bento': 0xe0dd, // places — applications, arrangement, bento, blocks, box
    'bento_outlined':
        0xeecd, // [outline] places — applications, arrangement, bento, blocks, box
    'bento_rounded':
        0xf5ba, // [round] places — applications, arrangement, bento, blocks, box
    'bento_sharp':
        0xe7db, // [sharp] places — applications, arrangement, bento, blocks, box
    'bike_scooter': 0xe0de, // maps — agile, automobile, bicycle, bike, car
    'bike_scooter_outlined':
        0xeece, // [outline] maps — agile, automobile, bicycle, bike, car
    'bike_scooter_rounded':
        0xf5bb, // [round] maps — agile, automobile, bicycle, bike, car
    'bike_scooter_sharp':
        0xe7dc, // [sharp] maps — agile, automobile, bicycle, bike, car
    'biotech': 0xe0df, // content — analysis, beaker, biology, biotech, chemical
    'biotech_outlined':
        0xeecf, // [outline] content — analysis, beaker, biology, biotech, chemical
    'biotech_rounded':
        0xf5bc, // [round] content — analysis, beaker, biology, biotech, chemical
    'biotech_sharp':
        0xe7dd, // [sharp] content — analysis, beaker, biology, biotech, chemical
    'blender':
        0xe0e0, // search — appliance, base, beverage preparation, blades, blend
    'blender_outlined':
        0xeed0, // [outline] search — appliance, base, beverage preparation, blades, blend
    'blender_rounded':
        0xf5bd, // [round] search — appliance, base, beverage preparation, blades, blend
    'blender_sharp':
        0xe7de, // [sharp] search — appliance, base, beverage preparation, blades, blend
    'blind':
        0xf0856, // social — abstract, accessibility, accessible, assist, blind
    'blind_outlined':
        0xf089d, // [outline] social — abstract, accessibility, accessible, assist, blind
    'blind_rounded':
        0xf087f, // [round] social — abstract, accessibility, accessible, assist, blind
    'blind_sharp':
        0xf0836, // [sharp] social — abstract, accessibility, accessible, assist, blind
    'blinds': 0xf078f, // home — adjust, automation, blinds, close, cover
    'blinds_closed':
        0xf0790, // home — architecture, blinds, block light, building, closed
    'blinds_closed_outlined':
        0xf06df, // [outline] home — architecture, blinds, block light, building, closed
    'blinds_closed_rounded':
        0xf07e7, // [round] home — architecture, blinds, block light, building, closed
    'blinds_closed_sharp':
        0xf0737, // [sharp] home — architecture, blinds, block light, building, closed
    'blinds_outlined':
        0xf06e0, // [outline] home — adjust, automation, blinds, close, cover
    'blinds_rounded':
        0xf07e8, // [round] home — adjust, automation, blinds, close, cover
    'blinds_sharp':
        0xf0738, // [sharp] home — adjust, automation, blinds, close, cover
    'block': 0xe0e1, // content — alert, avoid, ban, block, cancel
    'block_flipped': 0xe0e2, // content — avoid, block, cancel, close, disturb
    'block_outlined':
        0xeed1, // [outline] content — alert, avoid, ban, block, cancel
    'block_rounded':
        0xf5be, // [round] content — alert, avoid, ban, block, cancel
    'block_sharp': 0xe7df, // [sharp] content — alert, avoid, ban, block, cancel
    'bloodtype':
        0xe0e3, // device — abstract, analysis, blood, blood type, bloodtype
    'bloodtype_outlined':
        0xeed2, // [outline] device — abstract, analysis, blood, blood type, bloodtype
    'bloodtype_rounded':
        0xf5bf, // [round] device — abstract, analysis, blood, blood type, bloodtype
    'bloodtype_sharp':
        0xe7e0, // [sharp] device — abstract, analysis, blood, blood type, bloodtype
    'bluetooth':
        0xe0e4, // device — audio, bluetooth, cast, communication, connect
    'bluetooth_audio':
        0xe0e5, // notification — audio, bluetooth, communication, connect, connecting
    'bluetooth_audio_outlined':
        0xeed3, // [outline] notification — audio, bluetooth, communication, connect, connecting
    'bluetooth_audio_rounded':
        0xf5c0, // [round] notification — audio, bluetooth, communication, connect, connecting
    'bluetooth_audio_sharp':
        0xe7e1, // [sharp] notification — audio, bluetooth, communication, connect, connecting
    'bluetooth_connected':
        0xe0e6, // device — audio, bluetooth, cast, communication, connect
    'bluetooth_connected_outlined':
        0xeed4, // [outline] device — audio, bluetooth, cast, communication, connect
    'bluetooth_connected_rounded':
        0xf5c1, // [round] device — audio, bluetooth, cast, communication, connect
    'bluetooth_connected_sharp':
        0xe7e2, // [sharp] device — audio, bluetooth, cast, communication, connect
    'bluetooth_disabled':
        0xe0e7, // device — audio, bluetooth, cast, communication, connect
    'bluetooth_disabled_outlined':
        0xeed5, // [outline] device — audio, bluetooth, cast, communication, connect
    'bluetooth_disabled_rounded':
        0xf5c2, // [round] device — audio, bluetooth, cast, communication, connect
    'bluetooth_disabled_sharp':
        0xe7e3, // [sharp] device — audio, bluetooth, cast, communication, connect
    'bluetooth_drive':
        0xe0e8, // device — automobile, bluetooth, car, cars, cast
    'bluetooth_drive_outlined':
        0xeed6, // [outline] device — automobile, bluetooth, car, cars, cast
    'bluetooth_drive_rounded':
        0xf5c3, // [round] device — automobile, bluetooth, car, cars, cast
    'bluetooth_drive_sharp':
        0xe7e4, // [sharp] device — automobile, bluetooth, car, cars, cast
    'bluetooth_outlined':
        0xeed7, // [outline] device — audio, bluetooth, cast, communication, connect
    'bluetooth_rounded':
        0xf5c4, // [round] device — audio, bluetooth, cast, communication, connect
    'bluetooth_searching':
        0xe0e9, // device — audio, bluetooth, communication, connecting, connection
    'bluetooth_searching_outlined':
        0xeed8, // [outline] device — audio, bluetooth, communication, connecting, connection
    'bluetooth_searching_rounded':
        0xf5c5, // [round] device — audio, bluetooth, communication, connecting, connection
    'bluetooth_searching_sharp':
        0xe7e5, // [sharp] device — audio, bluetooth, communication, connecting, connection
    'bluetooth_sharp':
        0xe7e6, // [sharp] device — audio, bluetooth, cast, communication, connect
    'blur_circular': 0xe0ea, // image — aesthetic, art, blur, circle, circular
    'blur_circular_outlined':
        0xeed9, // [outline] image — aesthetic, art, blur, circle, circular
    'blur_circular_rounded':
        0xf5c6, // [round] image — aesthetic, art, blur, circle, circular
    'blur_circular_sharp':
        0xe7e7, // [sharp] image — aesthetic, art, blur, circle, circular
    'blur_linear': 0xe0eb, // image — adjust, art, blend, blur, dots
    'blur_linear_outlined':
        0xeeda, // [outline] image — adjust, art, blend, blur, dots
    'blur_linear_rounded':
        0xf5c7, // [round] image — adjust, art, blend, blur, dots
    'blur_linear_sharp':
        0xe7e8, // [sharp] image — adjust, art, blend, blur, dots
    'blur_off': 0xe0ec, // image — adjust, blur, blur off, clarity, clear
    'blur_off_outlined':
        0xeedb, // [outline] image — adjust, blur, blur off, clarity, clear
    'blur_off_rounded':
        0xf5c8, // [round] image — adjust, blur, blur off, clarity, clear
    'blur_off_sharp':
        0xe7e9, // [sharp] image — adjust, blur, blur off, clarity, clear
    'blur_on': 0xe0ed, // image — activate, active, blur, blur on, circle
    'blur_on_outlined':
        0xeedc, // [outline] image — activate, active, blur, blur on, circle
    'blur_on_rounded':
        0xf5c9, // [round] image — activate, active, blur, blur on, circle
    'blur_on_sharp':
        0xe7ea, // [sharp] image — activate, active, blur, blur on, circle
    'bolt': 0xe0ee, // content — alert, bolt, charge, current, danger
    'bolt_outlined':
        0xeedd, // [outline] content — alert, bolt, charge, current, danger
    'bolt_rounded':
        0xf5ca, // [round] content — alert, bolt, charge, current, danger
    'bolt_sharp':
        0xe7eb, // [sharp] content — alert, bolt, charge, current, danger
    'book': 0xe0ef, // action — academic, academy, book, bookmark, class
    'book_online':
        0xe0f0, // action — Android, OS, access, admission, appointment
    'book_online_outlined':
        0xeede, // [outline] action — Android, OS, access, admission, appointment
    'book_online_rounded':
        0xf5cb, // [round] action — Android, OS, access, admission, appointment
    'book_online_sharp':
        0xe7ec, // [sharp] action — Android, OS, access, admission, appointment
    'book_outlined':
        0xeedf, // [outline] action — academic, academy, book, bookmark, class
    'book_rounded':
        0xf5cc, // [round] action — academic, academy, book, bookmark, class
    'book_sharp':
        0xe7ed, // [sharp] action — academic, academy, book, bookmark, class
    'bookmark': 0xe0f1, // action — archive, article, book, bookmark, browser
    'bookmark_add': 0xe0f2, // action — +, add, archive, bookmark, document
    'bookmark_add_outlined':
        0xeee0, // [outline] action — +, add, archive, bookmark, document
    'bookmark_add_rounded':
        0xf5cd, // [round] action — +, add, archive, bookmark, document
    'bookmark_add_sharp':
        0xe7ee, // [sharp] action — +, add, archive, bookmark, document
    'bookmark_added': 0xe0f3, // action — add, added, approve, bookmark, check
    'bookmark_added_outlined':
        0xeee1, // [outline] action — add, added, approve, bookmark, check
    'bookmark_added_rounded':
        0xf5ce, // [round] action — add, added, approve, bookmark, check
    'bookmark_added_sharp':
        0xe7ef, // [sharp] action — add, added, approve, bookmark, check
    'bookmark_border':
        0xe0f4, // action — archive, article, book, bookmark, browser
    'bookmark_border_outlined':
        0xeee2, // [outline] action — archive, article, book, bookmark, browser
    'bookmark_border_rounded':
        0xf5cf, // [round] action — archive, article, book, bookmark, browser
    'bookmark_border_sharp':
        0xe7f0, // [sharp] action — archive, article, book, bookmark, browser
    'bookmark_outline':
        0xe0f4, // action — archive, article, book, bookmark, browser
    'bookmark_outline_outlined':
        0xeee2, // [outline] action — archive, article, book, bookmark, browser
    'bookmark_outline_rounded':
        0xf5cf, // [round] action — archive, article, book, bookmark, browser
    'bookmark_outline_sharp':
        0xe7f0, // [sharp] action — archive, article, book, bookmark, browser
    'bookmark_outlined':
        0xeee3, // [outline] action — archive, article, book, bookmark, browser
    'bookmark_remove':
        0xe0f5, // action — bookmark, clear, delete, document, erase
    'bookmark_remove_outlined':
        0xeee4, // [outline] action — bookmark, clear, delete, document, erase
    'bookmark_remove_rounded':
        0xf5d0, // [round] action — bookmark, clear, delete, document, erase
    'bookmark_remove_sharp':
        0xe7f1, // [sharp] action — bookmark, clear, delete, document, erase
    'bookmark_rounded':
        0xf5d1, // [round] action — archive, article, book, bookmark, browser
    'bookmark_sharp':
        0xe7f2, // [sharp] action — archive, article, book, bookmark, browser
    'bookmarks':
        0xe0f6, // action — bookmark, bookmarks, browser, document, favorite
    'bookmarks_outlined':
        0xeee5, // [outline] action — bookmark, bookmarks, browser, document, favorite
    'bookmarks_rounded':
        0xf5d2, // [round] action — bookmark, bookmarks, browser, document, favorite
    'bookmarks_sharp':
        0xe7f3, // [sharp] action — bookmark, bookmarks, browser, document, favorite
    'border_all': 0xe0f7, // editor — all, area, arrange, boundary, box
    'border_all_outlined':
        0xeee6, // [outline] editor — all, area, arrange, boundary, box
    'border_all_rounded':
        0xf5d3, // [round] editor — all, area, arrange, boundary, box
    'border_all_sharp':
        0xe7f4, // [sharp] editor — all, area, arrange, boundary, box
    'border_bottom':
        0xe0f8, // editor — add border, apply border, border bottom, border style, bottom
    'border_bottom_outlined':
        0xeee7, // [outline] editor — add border, apply border, border bottom, border style, bottom
    'border_bottom_rounded':
        0xf5d4, // [round] editor — add border, apply border, border bottom, border style, bottom
    'border_bottom_sharp':
        0xe7f5, // [sharp] editor — add border, apply border, border bottom, border style, bottom
    'border_clear':
        0xe0f9, // editor — border clear, border none, borderless, box, cancel
    'border_clear_outlined':
        0xeee8, // [outline] editor — border clear, border none, borderless, box, cancel
    'border_clear_rounded':
        0xf5d5, // [round] editor — border clear, border none, borderless, box, cancel
    'border_clear_sharp':
        0xe7f6, // [sharp] editor — border clear, border none, borderless, box, cancel
    'border_color': 0xe0fa, // editor — adjust, all, art, border color, change
    'border_color_outlined':
        0xeee9, // [outline] editor — adjust, all, art, border color, change
    'border_color_rounded':
        0xf5d6, // [round] editor — adjust, all, art, border color, change
    'border_color_sharp':
        0xe7f7, // [sharp] editor — adjust, all, art, border color, change
    'border_horizontal':
        0xe0fb, // editor — UI element, boundary, content break, dash, dashed
    'border_horizontal_outlined':
        0xeeea, // [outline] editor — UI element, boundary, content break, dash, dashed
    'border_horizontal_rounded':
        0xf5d7, // [round] editor — UI element, boundary, content break, dash, dashed
    'border_horizontal_sharp':
        0xe7f8, // [sharp] editor — UI element, boundary, content break, dash, dashed
    'border_inner':
        0xe0fc, // editor — alignment, area, border inner, boundary, box
    'border_inner_outlined':
        0xeeeb, // [outline] editor — alignment, area, border inner, boundary, box
    'border_inner_rounded':
        0xf5d8, // [round] editor — alignment, area, border inner, boundary, box
    'border_inner_sharp':
        0xe7f9, // [sharp] editor — alignment, area, border inner, boundary, box
    'border_left':
        0xe0fd, // editor — align left, alignment, border left, boundary, column
    'border_left_outlined':
        0xeeec, // [outline] editor — align left, alignment, border left, boundary, column
    'border_left_rounded':
        0xf5d9, // [round] editor — align left, alignment, border left, boundary, column
    'border_left_sharp':
        0xe7fa, // [sharp] editor — align left, alignment, border left, boundary, column
    'border_outer':
        0xe0fe, // editor — area, border outer, boundaries, box, cell
    'border_outer_outlined':
        0xeeed, // [outline] editor — area, border outer, boundaries, box, cell
    'border_outer_rounded':
        0xf5da, // [round] editor — area, border outer, boundaries, box, cell
    'border_outer_sharp':
        0xe7fb, // [sharp] editor — area, border outer, boundaries, box, cell
    'border_right':
        0xe0ff, // editor — alignment, border right, boundary, box, dash
    'border_right_outlined':
        0xeeee, // [outline] editor — alignment, border right, boundary, box, dash
    'border_right_rounded':
        0xf5db, // [round] editor — alignment, border right, boundary, box, dash
    'border_right_sharp':
        0xe7fc, // [sharp] editor — alignment, border right, boundary, box, dash
    'border_style': 0xe100, // editor — appearance, boundary, box, cell, color
    'border_style_outlined':
        0xeeef, // [outline] editor — appearance, boundary, box, cell, color
    'border_style_rounded':
        0xf5dc, // [round] editor — appearance, boundary, box, cell, color
    'border_style_sharp':
        0xe7fd, // [sharp] editor — appearance, boundary, box, cell, color
    'border_top': 0xe101, // editor — above, border top, boundary, cell, dash
    'border_top_outlined':
        0xeef0, // [outline] editor — above, border top, boundary, cell, dash
    'border_top_rounded':
        0xf5dd, // [round] editor — above, border top, boundary, cell, dash
    'border_top_sharp':
        0xe7fe, // [sharp] editor — above, border top, boundary, cell, dash
    'border_vertical':
        0xe102, // editor — alignment, boundaries, column, column break, columns
    'border_vertical_outlined':
        0xeef1, // [outline] editor — alignment, boundaries, column, column break, columns
    'border_vertical_rounded':
        0xf5de, // [round] editor — alignment, boundaries, column, column break, columns
    'border_vertical_sharp':
        0xe7ff, // [sharp] editor — alignment, boundaries, column, column break, columns
    'boy': 0xf04c8, // social — account, avatar, body, boy, bust
    'boy_outlined':
        0xf05c3, // [outline] social — account, avatar, body, boy, bust
    'boy_rounded': 0xf02e2, // [round] social — account, avatar, body, boy, bust
    'boy_sharp': 0xf03d5, // [sharp] social — account, avatar, body, boy, bust
    'branding_watermark':
        0xe103, // av — abstract, asset, branding, branding watermark, company
    'branding_watermark_outlined':
        0xeef2, // [outline] av — abstract, asset, branding, branding watermark, company
    'branding_watermark_rounded':
        0xf5df, // [round] av — abstract, asset, branding, branding watermark, company
    'branding_watermark_sharp':
        0xe800, // [sharp] av — abstract, asset, branding, branding watermark, company
    'breakfast_dining':
        0xe104, // maps — bakery, bread, breakfast, brunch, butter
    'breakfast_dining_outlined':
        0xeef3, // [outline] maps — bakery, bread, breakfast, brunch, butter
    'breakfast_dining_rounded':
        0xf5e0, // [round] maps — bakery, bread, breakfast, brunch, butter
    'breakfast_dining_sharp':
        0xe801, // [sharp] maps — bakery, bread, breakfast, brunch, butter
    'brightness_1': 0xe105, // image — 1, active, badge, brightness, centralized
    'brightness_1_outlined':
        0xeef4, // [outline] image — 1, active, badge, brightness, centralized
    'brightness_1_rounded':
        0xf5e1, // [round] image — 1, active, badge, brightness, centralized
    'brightness_1_sharp':
        0xe802, // [sharp] image — 1, active, badge, brightness, centralized
    'brightness_2': 0xe106, // image — 2, adjust, adjustment, brightness, circle
    'brightness_2_outlined':
        0xeef5, // [outline] image — 2, adjust, adjustment, brightness, circle
    'brightness_2_rounded':
        0xf5e2, // [round] image — 2, adjust, adjustment, brightness, circle
    'brightness_2_sharp':
        0xe803, // [sharp] image — 2, adjust, adjustment, brightness, circle
    'brightness_3':
        0xe107, // image — 3, adjust, astronomy, atmosphere, brightness
    'brightness_3_outlined':
        0xeef6, // [outline] image — 3, adjust, astronomy, atmosphere, brightness
    'brightness_3_rounded':
        0xf5e3, // [round] image — 3, adjust, astronomy, atmosphere, brightness
    'brightness_3_sharp':
        0xe804, // [sharp] image — 3, adjust, astronomy, atmosphere, brightness
    'brightness_4': 0xe108, // image — 4, adjustment, bar, brightness, circle
    'brightness_4_outlined':
        0xeef7, // [outline] image — 4, adjustment, bar, brightness, circle
    'brightness_4_rounded':
        0xf5e4, // [round] image — 4, adjustment, bar, brightness, circle
    'brightness_4_sharp':
        0xe805, // [sharp] image — 4, adjustment, bar, brightness, circle
    'brightness_5': 0xe109, // image — 5, adjust, brightness, circle, crescent
    'brightness_5_outlined':
        0xeef8, // [outline] image — 5, adjust, brightness, circle, crescent
    'brightness_5_rounded':
        0xf5e5, // [round] image — 5, adjust, brightness, circle, crescent
    'brightness_5_sharp':
        0xe806, // [sharp] image — 5, adjust, brightness, circle, crescent
    'brightness_6': 0xe10a, // image — 6, adjust, brightness, circle, contrast
    'brightness_6_outlined':
        0xeef9, // [outline] image — 6, adjust, brightness, circle, contrast
    'brightness_6_rounded':
        0xf5e6, // [round] image — 6, adjust, brightness, circle, contrast
    'brightness_6_sharp':
        0xe807, // [sharp] image — 6, adjust, brightness, circle, contrast
    'brightness_7':
        0xe10b, // image — 7, adjust, appearance, bright, bright light
    'brightness_7_outlined':
        0xeefa, // [outline] image — 7, adjust, appearance, bright, bright light
    'brightness_7_rounded':
        0xf5e7, // [round] image — 7, adjust, appearance, bright, bright light
    'brightness_7_sharp':
        0xe808, // [sharp] image — 7, adjust, appearance, bright, bright light
    'brightness_auto':
        0xe10c, // device — A, adjust, adjustment, ambient light, auto
    'brightness_auto_outlined':
        0xeefb, // [outline] device — A, adjust, adjustment, ambient light, auto
    'brightness_auto_rounded':
        0xf5e8, // [round] device — A, adjust, adjustment, ambient light, auto
    'brightness_auto_sharp':
        0xe809, // [sharp] device — A, adjust, adjustment, ambient light, auto
    'brightness_high':
        0xe10d, // device — adjust, adjustment, auto, beam, brightness
    'brightness_high_outlined':
        0xeefc, // [outline] device — adjust, adjustment, auto, beam, brightness
    'brightness_high_rounded':
        0xf5e9, // [round] device — adjust, adjustment, auto, beam, brightness
    'brightness_high_sharp':
        0xe80a, // [sharp] device — adjust, adjustment, auto, beam, brightness
    'brightness_low':
        0xe10e, // device — adjust, auto, battery, brightness, brightness low
    'brightness_low_outlined':
        0xeefd, // [outline] device — adjust, auto, battery, brightness, brightness low
    'brightness_low_rounded':
        0xf5ea, // [round] device — adjust, auto, battery, brightness, brightness low
    'brightness_low_sharp':
        0xe80b, // [sharp] device — adjust, auto, battery, brightness, brightness low
    'brightness_medium':
        0xe10f, // device — adjustment, auto, brightness, circle, configuration
    'brightness_medium_outlined':
        0xeefe, // [outline] device — adjustment, auto, brightness, circle, configuration
    'brightness_medium_rounded':
        0xf5eb, // [round] device — adjustment, auto, brightness, circle, configuration
    'brightness_medium_sharp':
        0xe80c, // [sharp] device — adjustment, auto, brightness, circle, configuration
    'broadcast_on_home':
        0xf0791, // home — airplay, audio, broadcast, cast, communication
    'broadcast_on_home_outlined':
        0xf06e1, // [outline] home — airplay, audio, broadcast, cast, communication
    'broadcast_on_home_rounded':
        0xf07e9, // [round] home — airplay, audio, broadcast, cast, communication
    'broadcast_on_home_sharp':
        0xf0739, // [sharp] home — airplay, audio, broadcast, cast, communication
    'broadcast_on_personal':
        0xf0792, // home — account, antenna, avatar, broadcast, communication
    'broadcast_on_personal_outlined':
        0xf06e2, // [outline] home — account, antenna, avatar, broadcast, communication
    'broadcast_on_personal_rounded':
        0xf07ea, // [round] home — account, antenna, avatar, broadcast, communication
    'broadcast_on_personal_sharp':
        0xf073a, // [sharp] home — account, antenna, avatar, broadcast, communication
    'broken_image': 0xe110, // image — alert, broken, content, corrupt, damaged
    'broken_image_outlined':
        0xeeff, // [outline] image — alert, broken, content, corrupt, damaged
    'broken_image_rounded':
        0xf5ec, // [round] image — alert, broken, content, corrupt, damaged
    'broken_image_sharp':
        0xe80d, // [sharp] image — alert, broken, content, corrupt, damaged
    'browse_gallery':
        0xf06ba, // action — album, artwork, assets, browse, browse gallery
    'browse_gallery_outlined':
        0xf03bc, // [outline] action — album, artwork, assets, browse, browse gallery
    'browse_gallery_rounded':
        0xf06c7, // [round] action — album, artwork, assets, browse, browse gallery
    'browse_gallery_sharp':
        0xf06ad, // [sharp] action — album, artwork, assets, browse, browse gallery
    'browser_not_supported':
        0xe111, // hardware — alert, asset, blocked, browser, computer
    'browser_not_supported_outlined':
        0xef00, // [outline] hardware — alert, asset, blocked, browser, computer
    'browser_not_supported_rounded':
        0xf5ed, // [round] hardware — alert, asset, blocked, browser, computer
    'browser_not_supported_sharp':
        0xe80e, // [sharp] hardware — alert, asset, blocked, browser, computer
    'browser_updated':
        0xf04c9, // hardware — Android, OS, arrow, browser, checkmark
    'browser_updated_outlined':
        0xf05c4, // [outline] hardware — Android, OS, arrow, browser, checkmark
    'browser_updated_rounded':
        0xf02e3, // [round] hardware — Android, OS, arrow, browser, checkmark
    'browser_updated_sharp':
        0xf03d6, // [sharp] hardware — Android, OS, arrow, browser, checkmark
    'brunch_dining':
        0xe112, // maps — bistro, breakfast, brunch, cafe, champagne
    'brunch_dining_outlined':
        0xef01, // [outline] maps — bistro, breakfast, brunch, cafe, champagne
    'brunch_dining_rounded':
        0xf5ee, // [round] maps — bistro, breakfast, brunch, cafe, champagne
    'brunch_dining_sharp':
        0xe80f, // [sharp] maps — bistro, breakfast, brunch, cafe, champagne
    'brush': 0xe113, // image — art, artist, artistic, bristle, brush
    'brush_outlined':
        0xef02, // [outline] image — art, artist, artistic, bristle, brush
    'brush_rounded':
        0xf5ef, // [round] image — art, artist, artistic, bristle, brush
    'brush_sharp':
        0xe810, // [sharp] image — art, artist, artistic, bristle, brush
    'bubble_chart': 0xe114, // editor — analysis, analytics, bar, bars, bubble
    'bubble_chart_outlined':
        0xef03, // [outline] editor — analysis, analytics, bar, bars, bubble
    'bubble_chart_rounded':
        0xf5f0, // [round] editor — analysis, analytics, bar, bars, bubble
    'bubble_chart_sharp':
        0xe811, // [sharp] editor — analysis, analytics, bar, bars, bubble
    'bug_report': 0xe115, // action — alert, animal, bug, case, circle
    'bug_report_outlined':
        0xef04, // [outline] action — alert, animal, bug, case, circle
    'bug_report_rounded':
        0xf5f1, // [round] action — alert, animal, bug, case, circle
    'bug_report_sharp':
        0xe812, // [sharp] action — alert, animal, bug, case, circle
    'build':
        0xe116, // action — adjust, adjustment, build, building, configuration
    'build_circle':
        0xe117, // action — adjust, build, circle, cog, configuration
    'build_circle_outlined':
        0xef05, // [outline] action — adjust, build, circle, cog, configuration
    'build_circle_rounded':
        0xf5f2, // [round] action — adjust, build, circle, cog, configuration
    'build_circle_sharp':
        0xe813, // [sharp] action — adjust, build, circle, cog, configuration
    'build_outlined':
        0xef06, // [outline] action — adjust, adjustment, build, building, configuration
    'build_rounded':
        0xf5f3, // [round] action — adjust, adjustment, build, building, configuration
    'build_sharp':
        0xe814, // [sharp] action — adjust, adjustment, build, building, configuration
    'bungalow':
        0xe118, // places — accommodation, architecture, building, bungalow, buy
    'bungalow_outlined':
        0xef07, // [outline] places — accommodation, architecture, building, bungalow, buy
    'bungalow_rounded':
        0xf5f4, // [round] places — accommodation, architecture, building, bungalow, buy
    'bungalow_sharp':
        0xe815, // [sharp] places — accommodation, architecture, building, bungalow, buy
    'burst_mode':
        0xe119, // image — burst, burst mode, camera, capture, continuous
    'burst_mode_outlined':
        0xef08, // [outline] image — burst, burst mode, camera, capture, continuous
    'burst_mode_rounded':
        0xf5f5, // [round] image — burst, burst mode, camera, capture, continuous
    'burst_mode_sharp':
        0xe816, // [sharp] image — burst, burst mode, camera, capture, continuous
    'bus_alert': 0xe11a, // maps — !, alarm, alert, attention, automobile
    'bus_alert_outlined':
        0xef09, // [outline] maps — !, alarm, alert, attention, automobile
    'bus_alert_rounded':
        0xf5f6, // [round] maps — !, alarm, alert, attention, automobile
    'bus_alert_sharp':
        0xe817, // [sharp] maps — !, alarm, alert, attention, automobile
    'business':
        0xe11b, // communication — address, apartment, architecture, building, business
    'business_center':
        0xe11c, // places — accessory, assets, bag, baggage, belongings
    'business_center_outlined':
        0xef0a, // [outline] places — accessory, assets, bag, baggage, belongings
    'business_center_rounded':
        0xf5f7, // [round] places — accessory, assets, bag, baggage, belongings
    'business_center_sharp':
        0xe818, // [sharp] places — accessory, assets, bag, baggage, belongings
    'business_outlined':
        0xef0b, // [outline] communication — address, apartment, architecture, building, business
    'business_rounded':
        0xf5f8, // [round] communication — address, apartment, architecture, building, business
    'business_sharp':
        0xe819, // [sharp] communication — address, apartment, architecture, building, business
    'cabin':
        0xe11d, // places — accommodation, architecture, building, cabin, camping
    'cabin_outlined':
        0xef0c, // [outline] places — accommodation, architecture, building, cabin, camping
    'cabin_rounded':
        0xf5f9, // [round] places — accommodation, architecture, building, cabin, camping
    'cabin_sharp':
        0xe81a, // [sharp] places — accommodation, architecture, building, cabin, camping
    'cable':
        0xe11e, // device — analog, cable, communication, connect, connection
    'cable_outlined':
        0xef0d, // [outline] device — analog, cable, communication, connect, connection
    'cable_rounded':
        0xf5fa, // [round] device — analog, cable, communication, connect, connection
    'cable_sharp':
        0xe81b, // [sharp] device — analog, cable, communication, connect, connection
    'cached': 0xe11f, // action — access, around, arrows, cache, cached
    'cached_outlined':
        0xef0e, // [outline] action — access, around, arrows, cache, cached
    'cached_rounded':
        0xf5fb, // [round] action — access, around, arrows, cache, cached
    'cached_sharp':
        0xe81c, // [sharp] action — access, around, arrows, cache, cached
    'cake': 0xe120, // social — add, anniversary, baked, baked goods, bakery
    'cake_outlined':
        0xef0f, // [outline] social — add, anniversary, baked, baked goods, bakery
    'cake_rounded':
        0xf5fc, // [round] social — add, anniversary, baked, baked goods, bakery
    'cake_sharp':
        0xe81d, // [sharp] social — add, anniversary, baked, baked goods, bakery
    'calculate': 0xe121, // content — +, -, =, addition, arithmetic
    'calculate_outlined':
        0xef10, // [outline] content — +, -, =, addition, arithmetic
    'calculate_rounded':
        0xf5fd, // [round] content — +, -, =, addition, arithmetic
    'calculate_sharp':
        0xe81e, // [sharp] content — +, -, =, addition, arithmetic
    'calendar_month':
        0xf06bb, // action — agenda, appointment, calendar, clock, date
    'calendar_month_outlined':
        0xf051f, // [outline] action — agenda, appointment, calendar, clock, date
    'calendar_month_rounded':
        0xf06c8, // [round] action — agenda, appointment, calendar, clock, date
    'calendar_month_sharp':
        0xf06ae, // [sharp] action — agenda, appointment, calendar, clock, date
    'calendar_today':
        0xe122, // action — agenda, appointment, booking, calendar, calendaricon
    'calendar_today_outlined':
        0xef11, // [outline] action — agenda, appointment, booking, calendar, calendaricon
    'calendar_today_rounded':
        0xf5fe, // [round] action — agenda, appointment, booking, calendar, calendaricon
    'calendar_today_sharp':
        0xe81f, // [sharp] action — agenda, appointment, booking, calendar, calendaricon
    'calendar_view_day':
        0xe123, // action — activity, agenda, appointment, appointments, calendar
    'calendar_view_day_outlined':
        0xef12, // [outline] action — activity, agenda, appointment, appointments, calendar
    'calendar_view_day_rounded':
        0xf5ff, // [round] action — activity, agenda, appointment, appointments, calendar
    'calendar_view_day_sharp':
        0xe820, // [sharp] action — activity, agenda, appointment, appointments, calendar
    'calendar_view_month':
        0xe124, // action — agenda, appointments, arrangement, block, booking
    'calendar_view_month_outlined':
        0xef13, // [outline] action — agenda, appointments, arrangement, block, booking
    'calendar_view_month_rounded':
        0xf600, // [round] action — agenda, appointments, arrangement, block, booking
    'calendar_view_month_sharp':
        0xe821, // [sharp] action — agenda, appointments, arrangement, block, booking
    'calendar_view_week':
        0xe125, // action — appointments, arrangement, calendar, columns, date
    'calendar_view_week_outlined':
        0xef14, // [outline] action — appointments, arrangement, calendar, columns, date
    'calendar_view_week_rounded':
        0xf601, // [round] action — appointments, arrangement, calendar, columns, date
    'calendar_view_week_sharp':
        0xe822, // [sharp] action — appointments, arrangement, calendar, columns, date
    'call':
        0xe126, // communication — audio, business, call, cell, communication
    'call_end': 0xe127, // communication — audio, call, cancel, cell, close
    'call_end_outlined':
        0xef15, // [outline] communication — audio, call, cancel, cell, close
    'call_end_rounded':
        0xf602, // [round] communication — audio, call, cancel, cell, close
    'call_end_sharp':
        0xe823, // [sharp] communication — audio, call, cancel, cell, close
    'call_made':
        0xe128, // communication — activity, angular, arrow, call, call made
    'call_made_outlined':
        0xef16, // [outline] communication — activity, angular, arrow, call, call made
    'call_made_rounded':
        0xf603, // [round] communication — activity, angular, arrow, call, call made
    'call_made_sharp':
        0xe824, // [sharp] communication — activity, angular, arrow, call, call made
    'call_merge':
        0xe129, // communication — arrow, arrows, branches, call, collapse
    'call_merge_outlined':
        0xef17, // [outline] communication — arrow, arrows, branches, call, collapse
    'call_merge_rounded':
        0xf604, // [round] communication — arrow, arrows, branches, call, collapse
    'call_merge_sharp':
        0xe825, // [sharp] communication — arrow, arrows, branches, call, collapse
    'call_missed':
        0xe12a, // communication — alert, angle, angle down, arrow, call
    'call_missed_outgoing':
        0xe12b, // communication — arrow, attempted, call, cellular, communication
    'call_missed_outgoing_outlined':
        0xef18, // [outline] communication — arrow, attempted, call, cellular, communication
    'call_missed_outgoing_rounded':
        0xf605, // [round] communication — arrow, attempted, call, cellular, communication
    'call_missed_outgoing_sharp':
        0xe826, // [sharp] communication — arrow, attempted, call, cellular, communication
    'call_missed_outlined':
        0xef19, // [outline] communication — alert, angle, angle down, arrow, call
    'call_missed_rounded':
        0xf606, // [round] communication — alert, angle, angle down, arrow, call
    'call_missed_sharp':
        0xe827, // [sharp] communication — alert, angle, angle down, arrow, call
    'call_outlined':
        0xef1a, // [outline] communication — audio, business, call, cell, communication
    'call_received':
        0xe12c, // communication — accept, alert, answering, arrival, arrow
    'call_received_outlined':
        0xef1b, // [outline] communication — accept, alert, answering, arrival, arrow
    'call_received_rounded':
        0xf607, // [round] communication — accept, alert, answering, arrival, arrow
    'call_received_sharp':
        0xe828, // [sharp] communication — accept, alert, answering, arrival, arrow
    'call_rounded':
        0xf608, // [round] communication — audio, business, call, cell, communication
    'call_sharp':
        0xe829, // [sharp] communication — audio, business, call, cell, communication
    'call_split':
        0xe12d, // communication — arrow, arrows, branch, call, call split
    'call_split_outlined':
        0xef1c, // [outline] communication — arrow, arrows, branch, call, call split
    'call_split_rounded':
        0xf609, // [round] communication — arrow, arrows, branch, call, call split
    'call_split_sharp':
        0xe82a, // [sharp] communication — arrow, arrows, branch, call, call split
    'call_to_action': 0xe12e, // av — active, alert, arrow, bar, call
    'call_to_action_outlined':
        0xef1d, // [outline] av — active, alert, arrow, bar, call
    'call_to_action_rounded':
        0xf60a, // [round] av — active, alert, arrow, bar, call
    'call_to_action_sharp':
        0xe82b, // [sharp] av — active, alert, arrow, bar, call
    'camera':
        0xe12f, // image — aperture, camera, capture, capture device, device
    'camera_alt': 0xe130, // image — alt, analog, camera, capture, circle
    'camera_alt_outlined':
        0xef1e, // [outline] image — alt, analog, camera, capture, circle
    'camera_alt_rounded':
        0xf60b, // [round] image — alt, analog, camera, capture, circle
    'camera_alt_sharp':
        0xe82c, // [sharp] image — alt, analog, camera, capture, circle
    'camera_enhance':
        0xe131, // action — adjustment, ai, aperture, artificial, automatic
    'camera_enhance_outlined':
        0xef1f, // [outline] action — adjustment, ai, aperture, artificial, automatic
    'camera_enhance_rounded':
        0xf60c, // [round] action — adjustment, ai, aperture, artificial, automatic
    'camera_enhance_sharp':
        0xe82d, // [sharp] action — adjustment, ai, aperture, artificial, automatic
    'camera_front': 0xe132, // image — body, camera, capture, circle, device
    'camera_front_outlined':
        0xef20, // [outline] image — body, camera, capture, circle, device
    'camera_front_rounded':
        0xf60d, // [round] image — body, camera, capture, circle, device
    'camera_front_sharp':
        0xe82e, // [sharp] image — body, camera, capture, circle, device
    'camera_indoor':
        0xe133, // search — architecture, automation, building, camera, cctv
    'camera_indoor_outlined':
        0xef21, // [outline] search — architecture, automation, building, camera, cctv
    'camera_indoor_rounded':
        0xf60e, // [round] search — architecture, automation, building, camera, cctv
    'camera_indoor_sharp':
        0xe82f, // [sharp] search — architecture, automation, building, camera, cctv
    'camera_outdoor':
        0xe134, // search — architecture, building, business, camera, cctv
    'camera_outdoor_outlined':
        0xef22, // [outline] search — architecture, building, business, camera, cctv
    'camera_outdoor_rounded':
        0xf60f, // [round] search — architecture, building, business, camera, cctv
    'camera_outdoor_sharp':
        0xe830, // [sharp] search — architecture, building, business, camera, cctv
    'camera_outlined':
        0xef23, // [outline] image — aperture, camera, capture, capture device, device
    'camera_rear':
        0xe135, // image — aperture, back camera, camera, camera mode, camera toggle
    'camera_rear_outlined':
        0xef24, // [outline] image — aperture, back camera, camera, camera mode, camera toggle
    'camera_rear_rounded':
        0xf610, // [round] image — aperture, back camera, camera, camera mode, camera toggle
    'camera_rear_sharp':
        0xe831, // [sharp] image — aperture, back camera, camera, camera mode, camera toggle
    'camera_roll':
        0xe136, // image — album, browse photos, camera, camera roll, digital photos
    'camera_roll_outlined':
        0xef25, // [outline] image — album, browse photos, camera, camera roll, digital photos
    'camera_roll_rounded':
        0xf611, // [round] image — album, browse photos, camera, camera roll, digital photos
    'camera_roll_sharp':
        0xe832, // [sharp] image — album, browse photos, camera, camera roll, digital photos
    'camera_rounded':
        0xf612, // [round] image — aperture, camera, capture, capture device, device
    'camera_sharp':
        0xe833, // [sharp] image — aperture, camera, capture, capture device, device
    'cameraswitch':
        0xe137, // device — arrow, arrows, back camera, camera, camera switch
    'cameraswitch_outlined':
        0xef26, // [outline] device — arrow, arrows, back camera, camera, camera switch
    'cameraswitch_rounded':
        0xf613, // [round] device — arrow, arrows, back camera, camera, camera switch
    'cameraswitch_sharp':
        0xe834, // [sharp] device — arrow, arrows, back camera, camera, camera switch
    'campaign':
        0xe138, // navigation — achievement, advertisement, alert, announcement, banner
    'campaign_outlined':
        0xef27, // [outline] navigation — achievement, advertisement, alert, announcement, banner
    'campaign_rounded':
        0xf614, // [round] navigation — achievement, advertisement, alert, announcement, banner
    'campaign_sharp':
        0xe835, // [sharp] navigation — achievement, advertisement, alert, announcement, banner
    'cancel': 0xe139, // navigation — abort, block, cancel, circle, clear
    'cancel_outlined':
        0xef28, // [outline] navigation — abort, block, cancel, circle, clear
    'cancel_presentation':
        0xe13a, // communication — abort, cancel, clear, close, conference
    'cancel_presentation_outlined':
        0xef29, // [outline] communication — abort, cancel, clear, close, conference
    'cancel_presentation_rounded':
        0xf615, // [round] communication — abort, cancel, clear, close, conference
    'cancel_presentation_sharp':
        0xe836, // [sharp] communication — abort, cancel, clear, close, conference
    'cancel_rounded':
        0xf616, // [round] navigation — abort, block, cancel, circle, clear
    'cancel_schedule_send':
        0xe13b, // action — abort, cancel, clear, command, communication
    'cancel_schedule_send_outlined':
        0xef2a, // [outline] action — abort, cancel, clear, command, communication
    'cancel_schedule_send_rounded':
        0xf617, // [round] action — abort, cancel, clear, command, communication
    'cancel_schedule_send_sharp':
        0xe837, // [sharp] action — abort, cancel, clear, command, communication
    'cancel_sharp':
        0xe838, // [sharp] navigation — abort, block, cancel, circle, clear
    'candlestick_chart':
        0xf04ca, // editor — analysis, analytics, bar graph, bars, business
    'candlestick_chart_outlined':
        0xf05c5, // [outline] editor — analysis, analytics, bar graph, bars, business
    'candlestick_chart_rounded':
        0xf02e4, // [round] editor — analysis, analytics, bar graph, bars, business
    'candlestick_chart_sharp':
        0xf03d7, // [sharp] editor — analysis, analytics, bar graph, bars, business
    'car_crash': 0xf0793, // maps — accident, alert, auto, automobile, broken
    'car_crash_outlined':
        0xf06e3, // [outline] maps — accident, alert, auto, automobile, broken
    'car_crash_rounded':
        0xf07eb, // [round] maps — accident, alert, auto, automobile, broken
    'car_crash_sharp':
        0xf073b, // [sharp] maps — accident, alert, auto, automobile, broken
    'car_rental':
        0xe13c, // maps — access, automobile, booking, booking service, car
    'car_rental_outlined':
        0xef2b, // [outline] maps — access, automobile, booking, booking service, car
    'car_rental_rounded':
        0xf618, // [round] maps — access, automobile, booking, booking service, car
    'car_rental_sharp':
        0xe839, // [sharp] maps — access, automobile, booking, booking service, car
    'car_repair':
        0xe13d, // maps — adjustments, assistance, auto, automobile, automotive
    'car_repair_outlined':
        0xef2c, // [outline] maps — adjustments, assistance, auto, automobile, automotive
    'car_repair_rounded':
        0xf619, // [round] maps — adjustments, assistance, auto, automobile, automotive
    'car_repair_sharp':
        0xe83a, // [sharp] maps — adjustments, assistance, auto, automobile, automotive
    'card_giftcard':
        0xe13e, // action — account, balance, bill, bonus, bonus points
    'card_giftcard_outlined':
        0xef2d, // [outline] action — account, balance, bill, bonus, bonus points
    'card_giftcard_rounded':
        0xf61a, // [round] action — account, balance, bill, bonus, bonus points
    'card_giftcard_sharp':
        0xe83b, // [sharp] action — account, balance, bill, bonus, bonus points
    'card_membership': 0xe13f, // action — access, account, bill, bookmark, card
    'card_membership_outlined':
        0xef2e, // [outline] action — access, account, bill, bookmark, card
    'card_membership_rounded':
        0xf61b, // [round] action — access, account, bill, bookmark, card
    'card_membership_sharp':
        0xe83c, // [sharp] action — access, account, bill, bookmark, card
    'card_travel': 0xe140, // action — accessory, bag, baggage, bill, briefcase
    'card_travel_outlined':
        0xef2f, // [outline] action — accessory, bag, baggage, bill, briefcase
    'card_travel_rounded':
        0xf61c, // [round] action — accessory, bag, baggage, bill, briefcase
    'card_travel_sharp':
        0xe83d, // [sharp] action — accessory, bag, baggage, bill, briefcase
    'carpenter':
        0xe141, // places — build, building, career, carpenter, construct
    'carpenter_outlined':
        0xef30, // [outline] places — build, building, career, carpenter, construct
    'carpenter_rounded':
        0xf61d, // [round] places — build, building, career, carpenter, construct
    'carpenter_sharp':
        0xe83e, // [sharp] places — build, building, career, carpenter, construct
    'cases': 0xe142, // image — administration, archive, bag, baggage, briefcase
    'cases_outlined':
        0xef31, // [outline] image — administration, archive, bag, baggage, briefcase
    'cases_rounded':
        0xf61e, // [round] image — administration, archive, bag, baggage, briefcase
    'cases_sharp':
        0xe83f, // [sharp] image — administration, archive, bag, baggage, briefcase
    'casino': 0xe143, // places — bet, betting, cards, casino, casino chip
    'casino_outlined':
        0xef32, // [outline] places — bet, betting, cards, casino, casino chip
    'casino_rounded':
        0xf61f, // [round] places — bet, betting, cards, casino, casino chip
    'casino_sharp':
        0xe840, // [sharp] places — bet, betting, cards, casino, casino chip
    'cast': 0xe144, // hardware — Android, OS, airplay, audio, broadcast
    'cast_connected': 0xe145, // hardware — Android, OS, airplay, audio, beaming
    'cast_connected_outlined':
        0xef33, // [outline] hardware — Android, OS, airplay, audio, beaming
    'cast_connected_rounded':
        0xf620, // [round] hardware — Android, OS, airplay, audio, beaming
    'cast_connected_sharp':
        0xe841, // [sharp] hardware — Android, OS, airplay, audio, beaming
    'cast_for_education':
        0xe146, // hardware — Android, OS, airplay, audio, broadcast
    'cast_for_education_outlined':
        0xef34, // [outline] hardware — Android, OS, airplay, audio, broadcast
    'cast_for_education_rounded':
        0xf621, // [round] hardware — Android, OS, airplay, audio, broadcast
    'cast_for_education_sharp':
        0xe842, // [sharp] hardware — Android, OS, airplay, audio, broadcast
    'cast_outlined':
        0xef35, // [outline] hardware — Android, OS, airplay, audio, broadcast
    'cast_rounded':
        0xf622, // [round] hardware — Android, OS, airplay, audio, broadcast
    'cast_sharp':
        0xe843, // [sharp] hardware — Android, OS, airplay, audio, broadcast
    'castle':
        0xf04cb, // maps — abode, ancient, architecture, battlement, building
    'castle_outlined':
        0xf05c6, // [outline] maps — abode, ancient, architecture, battlement, building
    'castle_rounded':
        0xf02e5, // [round] maps — abode, ancient, architecture, battlement, building
    'castle_sharp':
        0xf03d8, // [sharp] maps — abode, ancient, architecture, battlement, building
    'catching_pokemon':
        0xe147, // social — catching, go, pokemon, pokestop, travel
    'catching_pokemon_outlined':
        0xef36, // [outline] social — catching, go, pokemon, pokestop, travel
    'catching_pokemon_rounded':
        0xf623, // [round] social — catching, go, pokemon, pokestop, travel
    'catching_pokemon_sharp':
        0xe844, // [sharp] social — catching, go, pokemon, pokestop, travel
    'category': 0xe148, // maps — categories, category, chain, chains, chart
    'category_outlined':
        0xef37, // [outline] maps — categories, category, chain, chains, chart
    'category_rounded':
        0xf624, // [round] maps — categories, category, chain, chains, chart
    'category_sharp':
        0xe845, // [sharp] maps — categories, category, chain, chains, chart
    'celebration':
        0xe149, // maps — achievement, activity, award, birthday, burst
    'celebration_outlined':
        0xef38, // [outline] maps — achievement, activity, award, birthday, burst
    'celebration_rounded':
        0xf625, // [round] maps — achievement, activity, award, birthday, burst
    'celebration_sharp':
        0xe846, // [sharp] maps — achievement, activity, award, birthday, burst
    'cell_tower':
        0xf04cc, // communication — 5g, antenna, broadcast, building, casting
    'cell_tower_outlined':
        0xf05c7, // [outline] communication — 5g, antenna, broadcast, building, casting
    'cell_tower_rounded':
        0xf02e6, // [round] communication — 5g, antenna, broadcast, building, casting
    'cell_tower_sharp':
        0xf03d9, // [sharp] communication — 5g, antenna, broadcast, building, casting
    'cell_wifi':
        0xe14a, // communication — access, bars, cell, cellular, communication
    'cell_wifi_outlined':
        0xef39, // [outline] communication — access, bars, cell, cellular, communication
    'cell_wifi_rounded':
        0xf626, // [round] communication — access, bars, cell, cellular, communication
    'cell_wifi_sharp':
        0xe847, // [sharp] communication — access, bars, cell, cellular, communication
    'center_focus_strong':
        0xe14b, // image — accuracy, adjust, aiming, alignment, area
    'center_focus_strong_outlined':
        0xef3a, // [outline] image — accuracy, adjust, aiming, alignment, area
    'center_focus_strong_rounded':
        0xf627, // [round] image — accuracy, adjust, aiming, alignment, area
    'center_focus_strong_sharp':
        0xe848, // [sharp] image — accuracy, adjust, aiming, alignment, area
    'center_focus_weak':
        0xe14c, // image — aim, alignment, area, boundaries, camera
    'center_focus_weak_outlined':
        0xef3b, // [outline] image — aim, alignment, area, boundaries, camera
    'center_focus_weak_rounded':
        0xf628, // [round] image — aim, alignment, area, boundaries, camera
    'center_focus_weak_sharp':
        0xe849, // [sharp] image — aim, alignment, area, boundaries, camera
    'chair': 0xe14d, // search — balcony, bedroom, chair, comfort, couch
    'chair_alt':
        0xe14e, // search — cahir, chair, comfortable, furniture, graphic
    'chair_alt_outlined':
        0xef3c, // [outline] search — cahir, chair, comfortable, furniture, graphic
    'chair_alt_rounded':
        0xf629, // [round] search — cahir, chair, comfortable, furniture, graphic
    'chair_alt_sharp':
        0xe84a, // [sharp] search — cahir, chair, comfortable, furniture, graphic
    'chair_outlined':
        0xef3d, // [outline] search — balcony, bedroom, chair, comfort, couch
    'chair_rounded':
        0xf62a, // [round] search — balcony, bedroom, chair, comfort, couch
    'chair_sharp':
        0xe84b, // [sharp] search — balcony, bedroom, chair, comfort, couch
    'chalet': 0xe14f, // places — A-frame, alpine, architecture, building, cabin
    'chalet_outlined':
        0xef3e, // [outline] places — A-frame, alpine, architecture, building, cabin
    'chalet_rounded':
        0xf62b, // [round] places — A-frame, alpine, architecture, building, cabin
    'chalet_sharp':
        0xe84c, // [sharp] places — A-frame, alpine, architecture, building, cabin
    'change_circle': 0xe150, // content — alter, around, arrow, arrows, change
    'change_circle_outlined':
        0xef3f, // [outline] content — alter, around, arrow, arrows, change
    'change_circle_rounded':
        0xf62c, // [round] content — alter, around, arrow, arrows, change
    'change_circle_sharp':
        0xe84d, // [sharp] content — alter, around, arrow, arrows, change
    'change_history':
        0xe151, // action — audit trail, change, change history, chronology, development
    'change_history_outlined':
        0xef40, // [outline] action — audit trail, change, change history, chronology, development
    'change_history_rounded':
        0xf62d, // [round] action — audit trail, change, change history, chronology, development
    'change_history_sharp':
        0xe84e, // [sharp] action — audit trail, change, change history, chronology, development
    'charging_station': 0xe152, // places — Android, OS, battery, bolt, car
    'charging_station_outlined':
        0xef41, // [outline] places — Android, OS, battery, bolt, car
    'charging_station_rounded':
        0xf62e, // [round] places — Android, OS, battery, bolt, car
    'charging_station_sharp':
        0xe84f, // [sharp] places — Android, OS, battery, bolt, car
    'chat': 0xe153, // communication — alert, bubble, chat, comment, communicate
    'chat_bubble':
        0xe154, // communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_outline':
        0xe155, // communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_outline_outlined':
        0xef42, // [outline] communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_outline_rounded':
        0xf62f, // [round] communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_outline_sharp':
        0xe850, // [sharp] communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_outlined':
        0xef43, // [outline] communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_rounded':
        0xf630, // [round] communication — bubble, chat, chat outline, chatbox, comment
    'chat_bubble_sharp':
        0xe851, // [sharp] communication — bubble, chat, chat outline, chatbox, comment
    'chat_outlined':
        0xef44, // [outline] communication — alert, bubble, chat, comment, communicate
    'chat_rounded':
        0xf631, // [round] communication — alert, bubble, chat, comment, communicate
    'chat_sharp':
        0xe852, // [sharp] communication — alert, bubble, chat, comment, communicate
    'check': 0xe156, // navigation — !, acceptance, achievement, alert, apply
    'check_box': 0xe157, // toggle — activate, agree, approved, binary, box
    'check_box_outline_blank':
        0xe158, // toggle — blank, boundary, box, check, checkbox
    'check_box_outline_blank_outlined':
        0xef45, // [outline] toggle — blank, boundary, box, check, checkbox
    'check_box_outline_blank_rounded':
        0xf632, // [round] toggle — blank, boundary, box, check, checkbox
    'check_box_outline_blank_sharp':
        0xe853, // [sharp] toggle — blank, boundary, box, check, checkbox
    'check_box_outlined':
        0xef46, // [outline] toggle — activate, agree, approved, binary, box
    'check_box_rounded':
        0xf633, // [round] toggle — activate, agree, approved, binary, box
    'check_box_sharp':
        0xe854, // [sharp] toggle — activate, agree, approved, binary, box
    'check_circle':
        0xe159, // action — accept, approval, approve, check, checkmark
    'check_circle_outline':
        0xe15a, // action — accept, approval, approve, check, checkmark
    'check_circle_outline_outlined':
        0xef47, // [outline] action — accept, approval, approve, check, checkmark
    'check_circle_outline_rounded':
        0xf634, // [round] action — accept, approval, approve, check, checkmark
    'check_circle_outline_sharp':
        0xe855, // [sharp] action — accept, approval, approve, check, checkmark
    'check_circle_outlined':
        0xef48, // [outline] action — accept, approval, approve, check, checkmark
    'check_circle_rounded':
        0xf635, // [round] action — accept, approval, approve, check, checkmark
    'check_circle_sharp':
        0xe856, // [sharp] action — accept, approval, approve, check, checkmark
    'check_outlined':
        0xef49, // [outline] navigation — !, acceptance, achievement, alert, apply
    'check_rounded':
        0xf636, // [round] navigation — !, acceptance, achievement, alert, apply
    'check_sharp':
        0xe857, // [sharp] navigation — !, acceptance, achievement, alert, apply
    'checklist':
        0xe15b, // editor — align, alignment, approve, check, check marks
    'checklist_outlined':
        0xef4a, // [outline] editor — align, alignment, approve, check, check marks
    'checklist_rounded':
        0xf637, // [round] editor — align, alignment, approve, check, check marks
    'checklist_rtl':
        0xe15c, // editor — align, alignment, approve, bullet points, check
    'checklist_rtl_outlined':
        0xef4b, // [outline] editor — align, alignment, approve, bullet points, check
    'checklist_rtl_rounded':
        0xf638, // [round] editor — align, alignment, approve, bullet points, check
    'checklist_rtl_sharp':
        0xe858, // [sharp] editor — align, alignment, approve, bullet points, check
    'checklist_sharp':
        0xe859, // [sharp] editor — align, alignment, approve, check, check marks
    'checkroom':
        0xe15d, // places — apparel, bag, boutique, changing room, checkroom
    'checkroom_outlined':
        0xef4c, // [outline] places — apparel, bag, boutique, changing room, checkroom
    'checkroom_rounded':
        0xf639, // [round] places — apparel, bag, boutique, changing room, checkroom
    'checkroom_sharp':
        0xe85a, // [sharp] places — apparel, bag, boutique, changing room, checkroom
    'chevron_left': 0xe15e, // navigation — angle, arrow, arrows, back, backward
    'chevron_left_outlined':
        0xef4d, // [outline] navigation — angle, arrow, arrows, back, backward
    'chevron_left_rounded':
        0xf63a, // [round] navigation — angle, arrow, arrows, back, backward
    'chevron_left_sharp':
        0xe85b, // [sharp] navigation — angle, arrow, arrows, back, backward
    'chevron_right':
        0xe15f, // navigation — advance, angle, arrow, arrows, bracket
    'chevron_right_outlined':
        0xef4e, // [outline] navigation — advance, angle, arrow, arrows, bracket
    'chevron_right_rounded':
        0xf63b, // [round] navigation — advance, angle, arrow, arrows, bracket
    'chevron_right_sharp':
        0xe85c, // [sharp] navigation — advance, angle, arrow, arrows, bracket
    'child_care': 0xe160, // places — babies, baby, care, carriage, child
    'child_care_outlined':
        0xef4f, // [outline] places — babies, baby, care, carriage, child
    'child_care_rounded':
        0xf63c, // [round] places — babies, baby, care, carriage, child
    'child_care_sharp':
        0xe85d, // [sharp] places — babies, baby, care, carriage, child
    'child_friendly': 0xe161, // places — access, age, age rating, baby, body
    'child_friendly_outlined':
        0xef50, // [outline] places — access, age, age rating, baby, body
    'child_friendly_rounded':
        0xf63d, // [round] places — access, age, age rating, baby, body
    'child_friendly_sharp':
        0xe85e, // [sharp] places — access, age, age rating, baby, body
    'chrome_reader_mode':
        0xe162, // action — article, book, bookmark, browser, chrome
    'chrome_reader_mode_outlined':
        0xef51, // [outline] action — article, book, bookmark, browser, chrome
    'chrome_reader_mode_rounded':
        0xf63e, // [round] action — article, book, bookmark, browser, chrome
    'chrome_reader_mode_sharp':
        0xe85f, // [sharp] action — article, book, bookmark, browser, chrome
    'church':
        0xf04cd, // maps — architecture, building, cathedral, ceremony, chapel
    'church_outlined':
        0xf05c8, // [outline] maps — architecture, building, cathedral, ceremony, chapel
    'church_rounded':
        0xf02e7, // [round] maps — architecture, building, cathedral, ceremony, chapel
    'church_sharp':
        0xf03da, // [sharp] maps — architecture, building, cathedral, ceremony, chapel
    'circle': 0xe163, // image — active, angle, bullet, circle, circular
    'circle_notifications':
        0xe164, // action — active, activity, alarm, alert, alert bell
    'circle_notifications_outlined':
        0xef52, // [outline] action — active, activity, alarm, alert, alert bell
    'circle_notifications_rounded':
        0xf63f, // [round] action — active, activity, alarm, alert, alert bell
    'circle_notifications_sharp':
        0xe860, // [sharp] action — active, activity, alarm, alert, alert bell
    'circle_outlined':
        0xef53, // [outline] image — active, angle, bullet, circle, circular
    'circle_rounded':
        0xf640, // [round] image — active, angle, bullet, circle, circular
    'circle_sharp':
        0xe861, // [sharp] image — active, angle, bullet, circle, circular
    'class': 0xe165, // action — academic, academy, archive, book, bookmark
    'class_outlined':
        0xef54, // [outline] action — academic, academy, archive, book, bookmark
    'class_rounded':
        0xf641, // [round] action — academic, academy, archive, book, bookmark
    'class_sharp':
        0xe862, // [sharp] action — academic, academy, archive, book, bookmark
    'clean_hands': 0xe166, // social — bacteria, body, bubbles, care, clean
    'clean_hands_outlined':
        0xef55, // [outline] social — bacteria, body, bubbles, care, clean
    'clean_hands_rounded':
        0xf642, // [round] social — bacteria, body, bubbles, care, clean
    'clean_hands_sharp':
        0xe863, // [sharp] social — bacteria, body, bubbles, care, clean
    'cleaning_services': 0xe167, // maps — broom, care, chore, clean, cleaning
    'cleaning_services_outlined':
        0xef56, // [outline] maps — broom, care, chore, clean, cleaning
    'cleaning_services_rounded':
        0xf643, // [round] maps — broom, care, chore, clean, cleaning
    'cleaning_services_sharp':
        0xe864, // [sharp] maps — broom, care, chore, clean, cleaning
    'clear': 0xe168, // content — abort, alert, back, cancel, cancel button
    'clear_all': 0xe169, // communication — all, broom, clean, clear, clear all
    'clear_all_outlined':
        0xef57, // [outline] communication — all, broom, clean, clear, clear all
    'clear_all_rounded':
        0xf644, // [round] communication — all, broom, clean, clear, clear all
    'clear_all_sharp':
        0xe865, // [sharp] communication — all, broom, clean, clear, clear all
    'clear_outlined':
        0xef58, // [outline] content — abort, alert, back, cancel, cancel button
    'clear_rounded':
        0xf645, // [round] content — abort, alert, back, cancel, cancel button
    'clear_sharp':
        0xe866, // [sharp] content — abort, alert, back, cancel, cancel button
    'close': 0xe16a, // navigation — abort, alert, cancel, cancel button, clear
    'close_fullscreen':
        0xe16b, // action — arrow, arrows, arrows inward, box, close
    'close_fullscreen_outlined':
        0xef59, // [outline] action — arrow, arrows, arrows inward, box, close
    'close_fullscreen_rounded':
        0xf646, // [round] action — arrow, arrows, arrows inward, box, close
    'close_fullscreen_sharp':
        0xe867, // [sharp] action — arrow, arrows, arrows inward, box, close
    'close_outlined':
        0xef5a, // [outline] navigation — abort, alert, cancel, cancel button, clear
    'close_rounded':
        0xf647, // [round] navigation — abort, alert, cancel, cancel button, clear
    'close_sharp':
        0xe868, // [sharp] navigation — abort, alert, cancel, cancel button, clear
    'closed_caption':
        0xe16c, // av — accessibility, accessible, alphabet, audio, box
    'closed_caption_disabled':
        0xe16d, // av — accessibility, accessible, alphabet, audio, barrier
    'closed_caption_disabled_outlined':
        0xef5b, // [outline] av — accessibility, accessible, alphabet, audio, barrier
    'closed_caption_disabled_rounded':
        0xf648, // [round] av — accessibility, accessible, alphabet, audio, barrier
    'closed_caption_disabled_sharp':
        0xe869, // [sharp] av — accessibility, accessible, alphabet, audio, barrier
    'closed_caption_off':
        0xe16e, // av — accessibility, accessible, alphabet, audio, box
    'closed_caption_off_outlined':
        0xef5c, // [outline] av — accessibility, accessible, alphabet, audio, box
    'closed_caption_off_rounded':
        0xf649, // [round] av — accessibility, accessible, alphabet, audio, box
    'closed_caption_off_sharp':
        0xe86a, // [sharp] av — accessibility, accessible, alphabet, audio, box
    'closed_caption_outlined':
        0xef5d, // [outline] av — accessibility, accessible, alphabet, audio, box
    'closed_caption_rounded':
        0xf64a, // [round] av — accessibility, accessible, alphabet, audio, box
    'closed_caption_sharp':
        0xe86b, // [sharp] av — accessibility, accessible, alphabet, audio, box
    'cloud': 0xe16f, // file — air, atmosphere, climate, cloud, cloudy
    'cloud_circle': 0xe170, // file — backup, circle, circular, cloud, computing
    'cloud_circle_outlined':
        0xef5e, // [outline] file — backup, circle, circular, cloud, computing
    'cloud_circle_rounded':
        0xf64b, // [round] file — backup, circle, circular, cloud, computing
    'cloud_circle_sharp':
        0xe86c, // [sharp] file — backup, circle, circular, cloud, computing
    'cloud_done': 0xe171, // file — approve, available, backup, check, checkmark
    'cloud_done_outlined':
        0xef5f, // [outline] file — approve, available, backup, check, checkmark
    'cloud_done_rounded':
        0xf64c, // [round] file — approve, available, backup, check, checkmark
    'cloud_done_sharp':
        0xe86d, // [sharp] file — approve, available, backup, check, checkmark
    'cloud_download':
        0xe172, // file — access, arrow, backup, cloud, cloud computing
    'cloud_download_outlined':
        0xef60, // [outline] file — access, arrow, backup, cloud, cloud computing
    'cloud_download_rounded':
        0xf64d, // [round] file — access, arrow, backup, cloud, cloud computing
    'cloud_download_sharp':
        0xe86e, // [sharp] file — access, arrow, backup, cloud, cloud computing
    'cloud_off': 0xe173, // file — access, backup, broken, cloud, connection
    'cloud_off_outlined':
        0xef61, // [outline] file — access, backup, broken, cloud, connection
    'cloud_off_rounded':
        0xf64e, // [round] file — access, backup, broken, cloud, connection
    'cloud_off_sharp':
        0xe86f, // [sharp] file — access, backup, broken, cloud, connection
    'cloud_outlined':
        0xef62, // [outline] file — air, atmosphere, climate, cloud, cloudy
    'cloud_queue': 0xe174, // file — air, atmosphere, climate, cloud, cloudy
    'cloud_queue_outlined':
        0xef63, // [outline] file — air, atmosphere, climate, cloud, cloudy
    'cloud_queue_rounded':
        0xf64f, // [round] file — air, atmosphere, climate, cloud, cloudy
    'cloud_queue_sharp':
        0xe870, // [sharp] file — air, atmosphere, climate, cloud, cloudy
    'cloud_rounded':
        0xf650, // [round] file — air, atmosphere, climate, cloud, cloudy
    'cloud_sharp':
        0xe871, // [sharp] file — air, atmosphere, climate, cloud, cloudy
    'cloud_sync':
        0xf04ce, // file — around, arrow, backup, circular arrow, cloud
    'cloud_sync_outlined':
        0xf05c9, // [outline] file — around, arrow, backup, circular arrow, cloud
    'cloud_sync_rounded':
        0xf02e8, // [round] file — around, arrow, backup, circular arrow, cloud
    'cloud_sync_sharp':
        0xf03db, // [sharp] file — around, arrow, backup, circular arrow, cloud
    'cloud_upload':
        0xe175, // file — arrow, backup, cloud, computing, connection
    'cloud_upload_outlined':
        0xef64, // [outline] file — arrow, backup, cloud, computing, connection
    'cloud_upload_rounded':
        0xf651, // [round] file — arrow, backup, cloud, computing, connection
    'cloud_upload_sharp':
        0xe872, // [sharp] file — arrow, backup, cloud, computing, connection
    'cloudy_snowing':
        0xf04cf, // home — atmospheric, climate, cloud, cold, flakes
    'co2': 0xf04d0, // social — air, atom, carbon, carbon dioxide, chemical
    'co2_outlined':
        0xf05ca, // [outline] social — air, atom, carbon, carbon dioxide, chemical
    'co2_rounded':
        0xf02e9, // [round] social — air, atom, carbon, carbon dioxide, chemical
    'co2_sharp':
        0xf03dc, // [sharp] social — air, atom, carbon, carbon dioxide, chemical
    'co_present':
        0xf04d1, // communication — arrow, broadcast, broadcasting, cast, co-present
    'co_present_outlined':
        0xf05cb, // [outline] communication — arrow, broadcast, broadcasting, cast, co-present
    'co_present_rounded':
        0xf02ea, // [round] communication — arrow, broadcast, broadcasting, cast, co-present
    'co_present_sharp':
        0xf03dd, // [sharp] communication — arrow, broadcast, broadcasting, cast, co-present
    'code': 0xe176, // action — algorithm, backend, brackets, build, code
    'code_off':
        0xe177, // action — angle brackets, block, brackets, cancel, code
    'code_off_outlined':
        0xef65, // [outline] action — angle brackets, block, brackets, cancel, code
    'code_off_rounded':
        0xf652, // [round] action — angle brackets, block, brackets, cancel, code
    'code_off_sharp':
        0xe873, // [sharp] action — angle brackets, block, brackets, cancel, code
    'code_outlined':
        0xef66, // [outline] action — algorithm, backend, brackets, build, code
    'code_rounded':
        0xf653, // [round] action — algorithm, backend, brackets, build, code
    'code_sharp':
        0xe874, // [sharp] action — algorithm, backend, brackets, build, code
    'coffee': 0xe178, // search — barista, beverage, break, breakfast, cafe
    'coffee_maker':
        0xe179, // search — appliance, appliances, automation, beverage, breakfast
    'coffee_maker_outlined':
        0xef67, // [outline] search — appliance, appliances, automation, beverage, breakfast
    'coffee_maker_rounded':
        0xf654, // [round] search — appliance, appliances, automation, beverage, breakfast
    'coffee_maker_sharp':
        0xe875, // [sharp] search — appliance, appliances, automation, beverage, breakfast
    'coffee_outlined':
        0xef68, // [outline] search — barista, beverage, break, breakfast, cafe
    'coffee_rounded':
        0xf655, // [round] search — barista, beverage, break, breakfast, cafe
    'coffee_sharp':
        0xe876, // [sharp] search — barista, beverage, break, breakfast, cafe
    'collections':
        0xe17a, // image — adjustments, album, categorization, categorize, choices
    'collections_bookmark':
        0xe17b, // image — album, archive, bookmark, books, categorized
    'collections_bookmark_outlined':
        0xef69, // [outline] image — album, archive, bookmark, books, categorized
    'collections_bookmark_rounded':
        0xf656, // [round] image — album, archive, bookmark, books, categorized
    'collections_bookmark_sharp':
        0xe877, // [sharp] image — album, archive, bookmark, books, categorized
    'collections_outlined':
        0xef6a, // [outline] image — adjustments, album, categorization, categorize, choices
    'collections_rounded':
        0xf657, // [round] image — adjustments, album, categorization, categorize, choices
    'collections_sharp':
        0xe878, // [sharp] image — adjustments, album, categorization, categorize, choices
    'color_lens': 0xe17c, // image — appearance, art, artist, artistic, brush
    'color_lens_outlined':
        0xef6b, // [outline] image — appearance, art, artist, artistic, brush
    'color_lens_rounded':
        0xf658, // [round] image — appearance, art, artist, artistic, brush
    'color_lens_sharp':
        0xe879, // [sharp] image — appearance, art, artist, artistic, brush
    'colorize': 0xe17d, // image — adjustments, appearance, art, brush, color
    'colorize_outlined':
        0xef6c, // [outline] image — adjustments, appearance, art, brush, color
    'colorize_rounded':
        0xf659, // [round] image — adjustments, appearance, art, brush, color
    'colorize_sharp':
        0xe87a, // [sharp] image — adjustments, appearance, art, brush, color
    'comment':
        0xe17e, // communication — add, add comment, balloon, bubble, chat
    'comment_bank': 0xe17f, // action — archive, bank, bookmark, bubble, cchat
    'comment_bank_outlined':
        0xef6d, // [outline] action — archive, bank, bookmark, bubble, cchat
    'comment_bank_rounded':
        0xf65a, // [round] action — archive, bank, bookmark, bubble, cchat
    'comment_bank_sharp':
        0xe87b, // [sharp] action — archive, bank, bookmark, bubble, cchat
    'comment_outlined':
        0xef6e, // [outline] communication — add, add comment, balloon, bubble, chat
    'comment_rounded':
        0xf65b, // [round] communication — add, add comment, balloon, bubble, chat
    'comment_sharp':
        0xe87c, // [sharp] communication — add, add comment, balloon, bubble, chat
    'comments_disabled':
        0xf04d2, // communication — balloon, bar, blocked, bubble, censorship
    'comments_disabled_outlined':
        0xf05cc, // [outline] communication — balloon, bar, blocked, bubble, censorship
    'comments_disabled_rounded':
        0xf02eb, // [round] communication — balloon, bar, blocked, bubble, censorship
    'comments_disabled_sharp':
        0xf03de, // [sharp] communication — balloon, bar, blocked, bubble, censorship
    'commit': 0xf04d3, // action — accomplish, bind, branch, changes, circle
    'commit_outlined':
        0xf05cd, // [outline] action — accomplish, bind, branch, changes, circle
    'commit_rounded':
        0xf02ec, // [round] action — accomplish, bind, branch, changes, circle
    'commit_sharp':
        0xf03df, // [sharp] action — accomplish, bind, branch, changes, circle
    'commute':
        0xe180, // action — automobile, car, commute, destination, direction
    'commute_outlined':
        0xef6f, // [outline] action — automobile, car, commute, destination, direction
    'commute_rounded':
        0xf65c, // [round] action — automobile, car, commute, destination, direction
    'commute_sharp':
        0xe87d, // [sharp] action — automobile, car, commute, destination, direction
    'compare': 0xe181, // image — adjust, adjustment, analysis, analyze, chart
    'compare_arrows':
        0xe182, // action — alternative, arrow, arrows, balance, bidirectional
    'compare_arrows_outlined':
        0xef70, // [outline] action — alternative, arrow, arrows, balance, bidirectional
    'compare_arrows_rounded':
        0xf65d, // [round] action — alternative, arrow, arrows, balance, bidirectional
    'compare_arrows_sharp':
        0xe87e, // [sharp] action — alternative, arrow, arrows, balance, bidirectional
    'compare_outlined':
        0xef71, // [outline] image — adjust, adjustment, analysis, analyze, chart
    'compare_rounded':
        0xf65e, // [round] image — adjust, adjustment, analysis, analyze, chart
    'compare_sharp':
        0xe87f, // [sharp] image — adjust, adjustment, analysis, analyze, chart
    'compass_calibration':
        0xe183, // maps — accuracy, adjust, alignment, bearing, calibrate
    'compass_calibration_outlined':
        0xef72, // [outline] maps — accuracy, adjust, alignment, bearing, calibrate
    'compass_calibration_rounded':
        0xf65f, // [round] maps — accuracy, adjust, alignment, bearing, calibrate
    'compass_calibration_sharp':
        0xe880, // [sharp] maps — accuracy, adjust, alignment, bearing, calibrate
    'compost': 0xf04d4, // social — bin, bio, biomass, compost, compostable
    'compost_outlined':
        0xf05ce, // [outline] social — bin, bio, biomass, compost, compostable
    'compost_rounded':
        0xf02ed, // [round] social — bin, bio, biomass, compost, compostable
    'compost_sharp':
        0xf03e0, // [sharp] social — bin, bio, biomass, compost, compostable
    'compress': 0xe184, // action — adjust size, arrow, arrows, collide, compact
    'compress_outlined':
        0xef73, // [outline] action — adjust size, arrow, arrows, collide, compact
    'compress_rounded':
        0xf660, // [round] action — adjust size, arrow, arrows, collide, compact
    'compress_sharp':
        0xe881, // [sharp] action — adjust size, arrow, arrows, collide, compact
    'computer':
        0xe185, // hardware — Android, OS, accessory, chrome, communication
    'computer_outlined':
        0xef74, // [outline] hardware — Android, OS, accessory, chrome, communication
    'computer_rounded':
        0xf661, // [round] hardware — Android, OS, accessory, chrome, communication
    'computer_sharp':
        0xe882, // [sharp] hardware — Android, OS, accessory, chrome, communication
    'confirmation_num':
        0xe186, // notification — access, account, admission, authorization, booking
    'confirmation_num_outlined':
        0xef75, // [outline] notification — access, account, admission, authorization, booking
    'confirmation_num_rounded':
        0xf662, // [round] notification — access, account, admission, authorization, booking
    'confirmation_num_sharp':
        0xe883, // [sharp] notification — access, account, admission, authorization, booking
    'confirmation_number':
        0xe186, // notification — access, account, admission, authorization, booking
    'confirmation_number_outlined':
        0xef75, // [outline] notification — access, account, admission, authorization, booking
    'confirmation_number_rounded':
        0xf662, // [round] notification — access, account, admission, authorization, booking
    'confirmation_number_sharp':
        0xe883, // [sharp] notification — access, account, admission, authorization, booking
    'connect_without_contact':
        0xe187, // social — broadcast, communicating, communication, connect, connection
    'connect_without_contact_outlined':
        0xef76, // [outline] social — broadcast, communicating, communication, connect, connection
    'connect_without_contact_rounded':
        0xf663, // [round] social — broadcast, communicating, communication, connect, connection
    'connect_without_contact_sharp':
        0xe884, // [sharp] social — broadcast, communicating, communication, connect, connection
    'connected_tv': 0xe188, // hardware — Android, OS, airplay, cast, chrome
    'connected_tv_outlined':
        0xef77, // [outline] hardware — Android, OS, airplay, cast, chrome
    'connected_tv_rounded':
        0xf664, // [round] hardware — Android, OS, airplay, cast, chrome
    'connected_tv_sharp':
        0xe885, // [sharp] hardware — Android, OS, airplay, cast, chrome
    'connecting_airports':
        0xf04d5, // maps — air, aircraft, airplane, airplanes, airport
    'connecting_airports_outlined':
        0xf05cf, // [outline] maps — air, aircraft, airplane, airplanes, airport
    'connecting_airports_rounded':
        0xf02ee, // [round] maps — air, aircraft, airplane, airplanes, airport
    'connecting_airports_sharp':
        0xf03e1, // [sharp] maps — air, aircraft, airplane, airplanes, airport
    'construction':
        0xe189, // social — build, builder, building, carpenter, construction
    'construction_outlined':
        0xef78, // [outline] social — build, builder, building, carpenter, construction
    'construction_rounded':
        0xf665, // [round] social — build, builder, building, carpenter, construction
    'construction_sharp':
        0xe886, // [sharp] social — build, builder, building, carpenter, construction
    'contact_emergency':
        0xf0857, // communication — account, alert, assistance, avatar, call
    'contact_emergency_outlined':
        0xf089e, // [outline] communication — account, alert, assistance, avatar, call
    'contact_emergency_rounded':
        0xf0880, // [round] communication — account, alert, assistance, avatar, call
    'contact_emergency_sharp':
        0xf0837, // [sharp] communication — account, alert, assistance, avatar, call
    'contact_mail':
        0xe18a, // communication — account, address, address book, avatar, business card
    'contact_mail_outlined':
        0xef79, // [outline] communication — account, address, address book, avatar, business card
    'contact_mail_rounded':
        0xf666, // [round] communication — account, address, address book, avatar, business card
    'contact_mail_sharp':
        0xe887, // [sharp] communication — account, address, address book, avatar, business card
    'contact_page':
        0xe18b, // action — account, address book, avatar, book, business
    'contact_page_outlined':
        0xef7a, // [outline] action — account, address book, avatar, book, business
    'contact_page_rounded':
        0xf667, // [round] action — account, address book, avatar, book, business
    'contact_page_sharp':
        0xe888, // [sharp] action — account, address book, avatar, book, business
    'contact_phone':
        0xe18c, // communication — account, address book, avatar, call, circle
    'contact_phone_outlined':
        0xef7b, // [outline] communication — account, address book, avatar, call, circle
    'contact_phone_rounded':
        0xf668, // [round] communication — account, address book, avatar, call, circle
    'contact_phone_sharp':
        0xe889, // [sharp] communication — account, address book, avatar, call, circle
    'contact_support': 0xe18d, // action — ?, ask, assistance, bubble, chat
    'contact_support_outlined':
        0xef7c, // [outline] action — ?, ask, assistance, bubble, chat
    'contact_support_rounded':
        0xf669, // [round] action — ?, ask, assistance, bubble, chat
    'contact_support_sharp':
        0xe88a, // [sharp] action — ?, ask, assistance, bubble, chat
    'contactless':
        0xe18e, // action — banking, bluetooth, card reader, cash, commerce
    'contactless_outlined':
        0xef7d, // [outline] action — banking, bluetooth, card reader, cash, commerce
    'contactless_rounded':
        0xf66a, // [round] action — banking, bluetooth, card reader, cash, commerce
    'contactless_sharp':
        0xe88b, // [sharp] action — banking, bluetooth, card reader, cash, commerce
    'contacts':
        0xe18f, // communication — account, accounts, address book, avatar, avatars
    'contacts_outlined':
        0xef7e, // [outline] communication — account, accounts, address book, avatar, avatars
    'contacts_rounded':
        0xf66b, // [round] communication — account, accounts, address book, avatar, avatars
    'contacts_sharp':
        0xe88c, // [sharp] communication — account, accounts, address book, avatar, avatars
    'content_copy':
        0xe190, // content — clipboard, clone, content, copy, copy content
    'content_copy_outlined':
        0xef7f, // [outline] content — clipboard, clone, content, copy, copy content
    'content_copy_rounded':
        0xf66c, // [round] content — clipboard, clone, content, copy, copy content
    'content_copy_sharp':
        0xe88d, // [sharp] content — clipboard, clone, content, copy, copy content
    'content_cut': 0xe191, // content — audio, blade, clip, content, copy
    'content_cut_outlined':
        0xef80, // [outline] content — audio, blade, clip, content, copy
    'content_cut_rounded':
        0xf66d, // [round] content — audio, blade, clip, content, copy
    'content_cut_sharp':
        0xe88e, // [sharp] content — audio, blade, clip, content, copy
    'content_paste': 0xe192, // content — add, attach, clip, clipboard, content
    'content_paste_go':
        0xf04d6, // content — archive, arrow, box, clipboard, content
    'content_paste_go_outlined':
        0xf05d0, // [outline] content — archive, arrow, box, clipboard, content
    'content_paste_go_rounded':
        0xf02ef, // [round] content — archive, arrow, box, clipboard, content
    'content_paste_go_sharp':
        0xf03e2, // [sharp] content — archive, arrow, box, clipboard, content
    'content_paste_off':
        0xe193, // content — blocked, cancel paste, cannot paste, clear, clipboard
    'content_paste_off_outlined':
        0xef81, // [outline] content — blocked, cancel paste, cannot paste, clear, clipboard
    'content_paste_off_rounded':
        0xf66e, // [round] content — blocked, cancel paste, cannot paste, clear, clipboard
    'content_paste_off_sharp':
        0xe88f, // [sharp] content — blocked, cancel paste, cannot paste, clear, clipboard
    'content_paste_outlined':
        0xef82, // [outline] content — add, attach, clip, clipboard, content
    'content_paste_rounded':
        0xf66f, // [round] content — add, attach, clip, clipboard, content
    'content_paste_search':
        0xf04d7, // content — analysis, archive, clipboard, content, discover
    'content_paste_search_outlined':
        0xf05d1, // [outline] content — analysis, archive, clipboard, content, discover
    'content_paste_search_rounded':
        0xf02f0, // [round] content — analysis, archive, clipboard, content, discover
    'content_paste_search_sharp':
        0xf03e3, // [sharp] content — analysis, archive, clipboard, content, discover
    'content_paste_sharp':
        0xe890, // [sharp] content — add, attach, clip, clipboard, content
    'contrast': 0xf04d8, // image — adjust, adjustment, balance, black, bright
    'contrast_outlined':
        0xf05d2, // [outline] image — adjust, adjustment, balance, black, bright
    'contrast_rounded':
        0xf02f1, // [round] image — adjust, adjustment, balance, black, bright
    'contrast_sharp':
        0xf03e4, // [sharp] image — adjust, adjustment, balance, black, bright
    'control_camera': 0xe194, // av — adjust, apparatus, arrow, arrows, camera
    'control_camera_outlined':
        0xef83, // [outline] av — adjust, apparatus, arrow, arrows, camera
    'control_camera_rounded':
        0xf670, // [round] av — adjust, apparatus, arrow, arrows, camera
    'control_camera_sharp':
        0xe891, // [sharp] av — adjust, apparatus, arrow, arrows, camera
    'control_point': 0xe195, // image — +, add, append, circle, circular
    'control_point_duplicate':
        0xe196, // image — +, add, addmultiple, circle, circles
    'control_point_duplicate_outlined':
        0xef84, // [outline] image — +, add, addmultiple, circle, circles
    'control_point_duplicate_rounded':
        0xf671, // [round] image — +, add, addmultiple, circle, circles
    'control_point_duplicate_sharp':
        0xe892, // [sharp] image — +, add, addmultiple, circle, circles
    'control_point_outlined':
        0xef85, // [outline] image — +, add, append, circle, circular
    'control_point_rounded':
        0xf672, // [round] image — +, add, append, circle, circular
    'control_point_sharp':
        0xe893, // [sharp] image — +, add, append, circle, circular
    'conveyor_belt':
        0xf0858, // hardware — assembly, automated, automation, automation process, belt
    'cookie':
        0xf04d9, // social — alert, baked goods, biscuit, chocolate chip cookie, circle
    'cookie_outlined':
        0xf05d3, // [outline] social — alert, baked goods, biscuit, chocolate chip cookie, circle
    'cookie_rounded':
        0xf02f2, // [round] social — alert, baked goods, biscuit, chocolate chip cookie, circle
    'cookie_sharp':
        0xf03e5, // [sharp] social — alert, baked goods, biscuit, chocolate chip cookie, circle
    'copy': 0xe190, // content — clipboard, clone, content, copy, copy content
    'copy_all': 0xe197, // content — all, clone, content, copy, copy all
    'copy_all_outlined':
        0xef86, // [outline] content — all, clone, content, copy, copy all
    'copy_all_rounded':
        0xf673, // [round] content — all, clone, content, copy, copy all
    'copy_all_sharp':
        0xe894, // [sharp] content — all, clone, content, copy, copy all
    'copy_outlined':
        0xef7f, // [outline] content — clipboard, clone, content, copy, copy content
    'copy_rounded':
        0xf66c, // [round] content — clipboard, clone, content, copy, copy content
    'copy_sharp':
        0xe88d, // [sharp] content — clipboard, clone, content, copy, copy content
    'copyright': 0xe198, // action — agreement, alphabet, attribution, brand, c
    'copyright_outlined':
        0xef87, // [outline] action — agreement, alphabet, attribution, brand, c
    'copyright_rounded':
        0xf674, // [round] action — agreement, alphabet, attribution, brand, c
    'copyright_sharp':
        0xe895, // [sharp] action — agreement, alphabet, attribution, brand, c
    'coronavirus': 0xe199, // social — 19, bacteria, biohazard, biology, cell
    'coronavirus_outlined':
        0xef88, // [outline] social — 19, bacteria, biohazard, biology, cell
    'coronavirus_rounded':
        0xf675, // [round] social — 19, bacteria, biohazard, biology, cell
    'coronavirus_sharp':
        0xe896, // [sharp] social — 19, bacteria, biohazard, biology, cell
    'corporate_fare':
        0xe19a, // places — abstract, architecture, banking, building, business
    'corporate_fare_outlined':
        0xef89, // [outline] places — abstract, architecture, banking, building, business
    'corporate_fare_rounded':
        0xf676, // [round] places — abstract, architecture, banking, building, business
    'corporate_fare_sharp':
        0xe897, // [sharp] places — abstract, architecture, banking, building, business
    'cottage':
        0xe19b, // places — abode, accommodation, architecture, beach, building
    'cottage_outlined':
        0xef8a, // [outline] places — abode, accommodation, architecture, beach, building
    'cottage_rounded':
        0xf677, // [round] places — abode, accommodation, architecture, beach, building
    'cottage_sharp':
        0xe898, // [sharp] places — abode, accommodation, architecture, beach, building
    'countertops':
        0xe19c, // places — abstract, bathroom, block, building, commercial
    'countertops_outlined':
        0xef8b, // [outline] places — abstract, bathroom, block, building, commercial
    'countertops_rounded':
        0xf678, // [round] places — abstract, bathroom, block, building, commercial
    'countertops_sharp':
        0xe899, // [sharp] places — abstract, bathroom, block, building, commercial
    'create': 0xe19d, // content — alter, author, change, compose, create
    'create_new_folder': 0xe19e, // file — +, add, addition, archive, build
    'create_new_folder_outlined':
        0xef8c, // [outline] file — +, add, addition, archive, build
    'create_new_folder_rounded':
        0xf679, // [round] file — +, add, addition, archive, build
    'create_new_folder_sharp':
        0xe89a, // [sharp] file — +, add, addition, archive, build
    'create_outlined':
        0xef8d, // [outline] content — alter, author, change, compose, create
    'create_rounded':
        0xf67a, // [round] content — alter, author, change, compose, create
    'create_sharp':
        0xe89b, // [sharp] content — alter, author, change, compose, create
    'credit_card':
        0xe19f, // action — account, account information, amex, balance, bank
    'credit_card_off':
        0xe1a0, // action — banking, bill, blocked, broken, cancelled
    'credit_card_off_outlined':
        0xef8e, // [outline] action — banking, bill, blocked, broken, cancelled
    'credit_card_off_rounded':
        0xf67b, // [round] action — banking, bill, blocked, broken, cancelled
    'credit_card_off_sharp':
        0xe89c, // [sharp] action — banking, bill, blocked, broken, cancelled
    'credit_card_outlined':
        0xef8f, // [outline] action — account, account information, amex, balance, bank
    'credit_card_rounded':
        0xf67c, // [round] action — account, account information, amex, balance, bank
    'credit_card_sharp':
        0xe89d, // [sharp] action — account, account information, amex, balance, bank
    'credit_score':
        0xe1a1, // device — analysis, approve, assessment, banking, bill
    'credit_score_outlined':
        0xef90, // [outline] device — analysis, approve, assessment, banking, bill
    'credit_score_rounded':
        0xf67d, // [round] device — analysis, approve, assessment, banking, bill
    'credit_score_sharp':
        0xe89e, // [sharp] device — analysis, approve, assessment, banking, bill
    'crib': 0xe1a2, // places — babies, baby, baby bed, bassinet, bed
    'crib_outlined':
        0xef91, // [outline] places — babies, baby, baby bed, bassinet, bed
    'crib_rounded':
        0xf67e, // [round] places — babies, baby, baby bed, bassinet, bed
    'crib_sharp':
        0xe89f, // [sharp] places — babies, baby, baby bed, bassinet, bed
    'crisis_alert': 0xf0794, // maps — !, alarm, alert, attention, bullseye
    'crisis_alert_outlined':
        0xf06e4, // [outline] maps — !, alarm, alert, attention, bullseye
    'crisis_alert_rounded':
        0xf07ec, // [round] maps — !, alarm, alert, attention, bullseye
    'crisis_alert_sharp':
        0xf073c, // [sharp] maps — !, alarm, alert, attention, bullseye
    'crop': 0xe1a3, // image — adjust, adjustments, area, boundary, clip
    'crop_16_9':
        0xe1a4, // image — 16:9, adjust, adjustments, area, aspect ratio
    'crop_16_9_outlined':
        0xef92, // [outline] image — 16:9, adjust, adjustments, area, aspect ratio
    'crop_16_9_rounded':
        0xf67f, // [round] image — 16:9, adjust, adjustments, area, aspect ratio
    'crop_16_9_sharp':
        0xe8a0, // [sharp] image — 16:9, adjust, adjustments, area, aspect ratio
    'crop_3_2': 0xe1a5, // image — 3 by 2, 3:2, 3x2, adjust, adjustments
    'crop_3_2_outlined':
        0xef93, // [outline] image — 3 by 2, 3:2, 3x2, adjust, adjustments
    'crop_3_2_rounded':
        0xf680, // [round] image — 3 by 2, 3:2, 3x2, adjust, adjustments
    'crop_3_2_sharp':
        0xe8a1, // [sharp] image — 3 by 2, 3:2, 3x2, adjust, adjustments
    'crop_5_4': 0xe1a6, // image — 5:4, adjust, adjustments, area, aspect ratio
    'crop_5_4_outlined':
        0xef94, // [outline] image — 5:4, adjust, adjustments, area, aspect ratio
    'crop_5_4_rounded':
        0xf681, // [round] image — 5:4, adjust, adjustments, area, aspect ratio
    'crop_5_4_sharp':
        0xe8a2, // [sharp] image — 5:4, adjust, adjustments, area, aspect ratio
    'crop_7_5': 0xe1a7, // image — 7:5 ratio, adjust, adjustments, area, art
    'crop_7_5_outlined':
        0xef95, // [outline] image — 7:5 ratio, adjust, adjustments, area, art
    'crop_7_5_rounded':
        0xf682, // [round] image — 7:5 ratio, adjust, adjustments, area, art
    'crop_7_5_sharp':
        0xe8a3, // [sharp] image — 7:5 ratio, adjust, adjustments, area, art
    'crop_din':
        0xe1a8, // image — adjust, adjustments, area, area selection, aspect ratio
    'crop_din_outlined':
        0xef96, // [outline] image — adjust, adjustments, area, area selection, aspect ratio
    'crop_din_rounded':
        0xf683, // [round] image — adjust, adjustments, area, area selection, aspect ratio
    'crop_din_sharp':
        0xe8a4, // [sharp] image — adjust, adjustments, area, area selection, aspect ratio
    'crop_free': 0xe1a9, // image — adjust, adjustments, area, bounding box, box
    'crop_free_outlined':
        0xef97, // [outline] image — adjust, adjustments, area, bounding box, box
    'crop_free_rounded':
        0xf684, // [round] image — adjust, adjustments, area, bounding box, box
    'crop_free_sharp':
        0xe8a5, // [sharp] image — adjust, adjustments, area, bounding box, box
    'crop_landscape':
        0xe1aa, // image — adjust, adjustments, area, aspect ratio, crop
    'crop_landscape_outlined':
        0xef98, // [outline] image — adjust, adjustments, area, aspect ratio, crop
    'crop_landscape_rounded':
        0xf685, // [round] image — adjust, adjustments, area, aspect ratio, crop
    'crop_landscape_sharp':
        0xe8a6, // [sharp] image — adjust, adjustments, area, aspect ratio, crop
    'crop_original': 0xe1ab, // image — add, adjust, adjustments, album, area
    'crop_original_outlined':
        0xef99, // [outline] image — add, adjust, adjustments, album, area
    'crop_original_rounded':
        0xf686, // [round] image — add, adjust, adjustments, album, area
    'crop_original_sharp':
        0xe8a7, // [sharp] image — add, adjust, adjustments, album, area
    'crop_outlined':
        0xef9a, // [outline] image — adjust, adjustments, area, boundary, clip
    'crop_portrait':
        0xe1ac, // image — adjust, adjustments, area, aspect ratio, crop
    'crop_portrait_outlined':
        0xef9b, // [outline] image — adjust, adjustments, area, aspect ratio, crop
    'crop_portrait_rounded':
        0xf687, // [round] image — adjust, adjustments, area, aspect ratio, crop
    'crop_portrait_sharp':
        0xe8a8, // [sharp] image — adjust, adjustments, area, aspect ratio, crop
    'crop_rotate': 0xe1ad, // image — adjust, adjustments, area, arrow, arrows
    'crop_rotate_outlined':
        0xef9c, // [outline] image — adjust, adjustments, area, arrow, arrows
    'crop_rotate_rounded':
        0xf688, // [round] image — adjust, adjustments, area, arrow, arrows
    'crop_rotate_sharp':
        0xe8a9, // [sharp] image — adjust, adjustments, area, arrow, arrows
    'crop_rounded':
        0xf689, // [round] image — adjust, adjustments, area, boundary, clip
    'crop_sharp':
        0xe8aa, // [sharp] image — adjust, adjustments, area, boundary, clip
    'crop_square':
        0xe1ae, // image — adjust, adjustments, area, area selection, aspect ratio
    'crop_square_outlined':
        0xef9d, // [outline] image — adjust, adjustments, area, area selection, aspect ratio
    'crop_square_rounded':
        0xf68a, // [round] image — adjust, adjustments, area, area selection, aspect ratio
    'crop_square_sharp':
        0xe8ab, // [sharp] image — adjust, adjustments, area, area selection, aspect ratio
    'cruelty_free':
        0xf04da, // social — animal, animal friendly, animal testing, animal welfare, beauty
    'cruelty_free_outlined':
        0xf05d4, // [outline] social — animal, animal friendly, animal testing, animal welfare, beauty
    'cruelty_free_rounded':
        0xf02f3, // [round] social — animal, animal friendly, animal testing, animal welfare, beauty
    'cruelty_free_sharp':
        0xf03e6, // [sharp] social — animal, animal friendly, animal testing, animal welfare, beauty
    'css':
        0xf04db, // action — alphabet, brackets, browser, cascading stylesheets, character
    'css_outlined':
        0xf05d5, // [outline] action — alphabet, brackets, browser, cascading stylesheets, character
    'css_rounded':
        0xf02f4, // [round] action — alphabet, brackets, browser, cascading stylesheets, character
    'css_sharp':
        0xf03e7, // [sharp] action — alphabet, brackets, browser, cascading stylesheets, character
    'currency_bitcoin':
        0xf06bc, // image — bill, bitcoin, blockchain, card, cash
    'currency_bitcoin_outlined':
        0xf054a, // [outline] image — bill, bitcoin, blockchain, card, cash
    'currency_bitcoin_rounded':
        0xf06c9, // [round] image — bill, bitcoin, blockchain, card, cash
    'currency_bitcoin_sharp':
        0xf06af, // [sharp] image — bill, bitcoin, blockchain, card, cash
    'currency_exchange':
        0xf04dc, // action — 360, around, arrow, arrows, banking
    'currency_exchange_outlined':
        0xf05d6, // [outline] action — 360, around, arrow, arrows, banking
    'currency_exchange_rounded':
        0xf02f5, // [round] action — 360, around, arrow, arrows, banking
    'currency_exchange_sharp':
        0xf03e8, // [sharp] action — 360, around, arrow, arrows, banking
    'currency_franc': 0xf04dd, // image — banking, bill, budget, capital, card
    'currency_franc_outlined':
        0xf05d7, // [outline] image — banking, bill, budget, capital, card
    'currency_franc_rounded':
        0xf02f6, // [round] image — banking, bill, budget, capital, card
    'currency_franc_sharp':
        0xf03e9, // [sharp] image — banking, bill, budget, capital, card
    'currency_lira': 0xf04de, // image — bar, bill, buy, capital letter, card
    'currency_lira_outlined':
        0xf05d8, // [outline] image — bar, bill, buy, capital letter, card
    'currency_lira_rounded':
        0xf02f7, // [round] image — bar, bill, buy, capital letter, card
    'currency_lira_sharp':
        0xf03ea, // [sharp] image — bar, bill, buy, capital letter, card
    'currency_pound':
        0xf04df, // image — accounting, alphabet, banking, bill, british pound
    'currency_pound_outlined':
        0xf05d9, // [outline] image — accounting, alphabet, banking, bill, british pound
    'currency_pound_rounded':
        0xf02f8, // [round] image — accounting, alphabet, banking, bill, british pound
    'currency_pound_sharp':
        0xf03eb, // [sharp] image — accounting, alphabet, banking, bill, british pound
    'currency_ruble':
        0xf04e0, // image — banking, bill, billing, budget, business
    'currency_ruble_outlined':
        0xf05da, // [outline] image — banking, bill, billing, budget, business
    'currency_ruble_rounded':
        0xf02f9, // [round] image — banking, bill, billing, budget, business
    'currency_ruble_sharp':
        0xf03ec, // [sharp] image — banking, bill, billing, budget, business
    'currency_rupee': 0xf04e1, // image — bank, banking, bill, buy, card
    'currency_rupee_outlined':
        0xf05db, // [outline] image — bank, banking, bill, buy, card
    'currency_rupee_rounded':
        0xf02fa, // [round] image — bank, banking, bill, buy, card
    'currency_rupee_sharp':
        0xf03ed, // [sharp] image — bank, banking, bill, buy, card
    'currency_yen': 0xf04e2, // image — bank, banking, bill, capital, card
    'currency_yen_outlined':
        0xf05dc, // [outline] image — bank, banking, bill, capital, card
    'currency_yen_rounded':
        0xf02fb, // [round] image — bank, banking, bill, capital, card
    'currency_yen_sharp':
        0xf03ee, // [sharp] image — bank, banking, bill, capital, card
    'currency_yuan': 0xf04e3, // image — banking, bill, business, buy, card
    'currency_yuan_outlined':
        0xf05dd, // [outline] image — banking, bill, business, buy, card
    'currency_yuan_rounded':
        0xf02fc, // [round] image — banking, bill, business, buy, card
    'currency_yuan_sharp':
        0xf03ef, // [sharp] image — banking, bill, business, buy, card
    'curtains': 0xf0795, // home — bedroom, blinds, closed, cover, curtains
    'curtains_closed': 0xf0796, // home — barrier, blinds, block, closed, cloth
    'curtains_closed_outlined':
        0xf06e5, // [outline] home — barrier, blinds, block, closed, cloth
    'curtains_closed_rounded':
        0xf07ed, // [round] home — barrier, blinds, block, closed, cloth
    'curtains_closed_sharp':
        0xf073d, // [sharp] home — barrier, blinds, block, closed, cloth
    'curtains_outlined':
        0xf06e6, // [outline] home — bedroom, blinds, closed, cover, curtains
    'curtains_rounded':
        0xf07ee, // [round] home — bedroom, blinds, closed, cover, curtains
    'curtains_sharp':
        0xf073e, // [sharp] home — bedroom, blinds, closed, cover, curtains
    'cut': 0xe191, // content — audio, blade, clip, content, copy
    'cut_outlined':
        0xef80, // [outline] content — audio, blade, clip, content, copy
    'cut_rounded':
        0xf66d, // [round] content — audio, blade, clip, content, copy
    'cut_sharp': 0xe88e, // [sharp] content — audio, blade, clip, content, copy
    'cyclone': 0xf0797, // social — air, airflow, alert, atmosphere, chaos
    'cyclone_outlined':
        0xf06e7, // [outline] social — air, airflow, alert, atmosphere, chaos
    'cyclone_rounded':
        0xf07ef, // [round] social — air, airflow, alert, atmosphere, chaos
    'cyclone_sharp':
        0xf073f, // [sharp] social — air, airflow, alert, atmosphere, chaos
    'dangerous':
        0xe1af, // action — alarming, alert, attention, be careful, broken
    'dangerous_outlined':
        0xef9e, // [outline] action — alarming, alert, attention, be careful, broken
    'dangerous_rounded':
        0xf68b, // [round] action — alarming, alert, attention, be careful, broken
    'dangerous_sharp':
        0xe8ac, // [sharp] action — alarming, alert, attention, be careful, broken
    'dark_mode':
        0xe1b0, // device — accessibility, ambient, appearance, atmosphere, bedtime
    'dark_mode_outlined':
        0xef9f, // [outline] device — accessibility, ambient, appearance, atmosphere, bedtime
    'dark_mode_rounded':
        0xf68c, // [round] device — accessibility, ambient, appearance, atmosphere, bedtime
    'dark_mode_sharp':
        0xe8ad, // [sharp] device — accessibility, ambient, appearance, atmosphere, bedtime
    'dashboard':
        0xe1b1, // action — add, administration, analytics, cards, chart
    'dashboard_customize':
        0xe1b2, // action — adjust, arrange, blocks, boxes, cards
    'dashboard_customize_outlined':
        0xefa0, // [outline] action — adjust, arrange, blocks, boxes, cards
    'dashboard_customize_rounded':
        0xf68d, // [round] action — adjust, arrange, blocks, boxes, cards
    'dashboard_customize_sharp':
        0xe8ae, // [sharp] action — adjust, arrange, blocks, boxes, cards
    'dashboard_outlined':
        0xefa1, // [outline] action — add, administration, analytics, cards, chart
    'dashboard_rounded':
        0xf68e, // [round] action — add, administration, analytics, cards, chart
    'dashboard_sharp':
        0xe8af, // [sharp] action — add, administration, analytics, cards, chart
    'data_array': 0xf04e4, // editor — array, block, brackets, code, coder
    'data_array_outlined':
        0xf05de, // [outline] editor — array, block, brackets, code, coder
    'data_array_rounded':
        0xf02fd, // [round] editor — array, block, brackets, code, coder
    'data_array_sharp':
        0xf03f0, // [sharp] editor — array, block, brackets, code, coder
    'data_exploration':
        0xf04e5, // action — analysis, analytics, arrow, bi, business intelligence
    'data_exploration_outlined':
        0xf05df, // [outline] action — analysis, analytics, arrow, bi, business intelligence
    'data_exploration_rounded':
        0xf02fe, // [round] action — analysis, analytics, arrow, bi, business intelligence
    'data_exploration_sharp':
        0xf03f1, // [sharp] action — analysis, analytics, arrow, bi, business intelligence
    'data_object':
        0xf04e6, // editor — access, analytics, brackets, categorize, cloud
    'data_object_outlined':
        0xf05e0, // [outline] editor — access, analytics, brackets, categorize, cloud
    'data_object_rounded':
        0xf02ff, // [round] editor — access, analytics, brackets, categorize, cloud
    'data_object_sharp':
        0xf03f2, // [sharp] editor — access, analytics, brackets, categorize, cloud
    'data_saver_off':
        0xe1b3, // device — analytics, bar, bars, blocking, canceled
    'data_saver_off_outlined':
        0xefa2, // [outline] device — analytics, bar, bars, blocking, canceled
    'data_saver_off_rounded':
        0xf68f, // [round] device — analytics, bar, bars, blocking, canceled
    'data_saver_off_sharp':
        0xe8b0, // [sharp] device — analytics, bar, bars, blocking, canceled
    'data_saver_on': 0xe1b4, // device — +, active, add, analytics, arrow
    'data_saver_on_outlined':
        0xefa3, // [outline] device — +, active, add, analytics, arrow
    'data_saver_on_rounded':
        0xf690, // [round] device — +, active, add, analytics, arrow
    'data_saver_on_sharp':
        0xe8b1, // [sharp] device — +, active, add, analytics, arrow
    'data_thresholding':
        0xf04e7, // action — analysis, chart, configuration, criteria, data analysis
    'data_thresholding_outlined':
        0xf05e1, // [outline] action — analysis, chart, configuration, criteria, data analysis
    'data_thresholding_rounded':
        0xf0300, // [round] action — analysis, chart, configuration, criteria, data analysis
    'data_thresholding_sharp':
        0xf03f3, // [sharp] action — analysis, chart, configuration, criteria, data analysis
    'data_usage':
        0xe1b5, // device — analytics, blocking, canceled, cellular, chart
    'data_usage_outlined':
        0xefa4, // [outline] device — analytics, blocking, canceled, cellular, chart
    'data_usage_rounded':
        0xf691, // [round] device — analytics, blocking, canceled, cellular, chart
    'data_usage_sharp':
        0xe8b2, // [sharp] device — analytics, blocking, canceled, cellular, chart
    'dataset':
        0xf0798, // device — archive, cloud, columns, data entry, data management
    'dataset_linked':
        0xf0799, // device — browser, chain, chain link, connect, connected
    'dataset_linked_outlined':
        0xf06e8, // [outline] device — browser, chain, chain link, connect, connected
    'dataset_linked_rounded':
        0xf07f0, // [round] device — browser, chain, chain link, connect, connected
    'dataset_linked_sharp':
        0xf0740, // [sharp] device — browser, chain, chain link, connect, connected
    'dataset_outlined':
        0xf06e9, // [outline] device — archive, cloud, columns, data entry, data management
    'dataset_rounded':
        0xf07f1, // [round] device — archive, cloud, columns, data entry, data management
    'dataset_sharp':
        0xf0741, // [sharp] device — archive, cloud, columns, data entry, data management
    'date_range':
        0xe1b6, // action — agenda, appointment, booking, calendar, calendar grid
    'date_range_outlined':
        0xefa5, // [outline] action — agenda, appointment, booking, calendar, calendar grid
    'date_range_rounded':
        0xf692, // [round] action — agenda, appointment, booking, calendar, calendar grid
    'date_range_sharp':
        0xe8b3, // [sharp] action — agenda, appointment, booking, calendar, calendar grid
    'deblur':
        0xf04e8, // image — adjust, adjustment, clarity, contrast, correction
    'deblur_outlined':
        0xf05e2, // [outline] image — adjust, adjustment, clarity, contrast, correction
    'deblur_rounded':
        0xf0301, // [round] image — adjust, adjustment, clarity, contrast, correction
    'deblur_sharp':
        0xf03f4, // [sharp] image — adjust, adjustment, clarity, contrast, correction
    'deck': 0xe1b7, // social — aligned, angled, bridge, cards, cards deck
    'deck_outlined':
        0xefa6, // [outline] social — aligned, angled, bridge, cards, cards deck
    'deck_rounded':
        0xf693, // [round] social — aligned, angled, bridge, cards, cards deck
    'deck_sharp':
        0xe8b4, // [sharp] social — aligned, angled, bridge, cards, cards deck
    'dehaze': 0xe1b8, // image — adjust, adjustments, air, atmospheric, clarity
    'dehaze_outlined':
        0xefa7, // [outline] image — adjust, adjustments, air, atmospheric, clarity
    'dehaze_rounded':
        0xf694, // [round] image — adjust, adjustments, air, atmospheric, clarity
    'dehaze_sharp':
        0xe8b5, // [sharp] image — adjust, adjustments, air, atmospheric, clarity
    'delete': 0xe1b9, // action — basket, bin, can, cancel, clean up
    'delete_forever': 0xe1ba, // action — archive, bin, can, cancel, clean
    'delete_forever_outlined':
        0xefa8, // [outline] action — archive, bin, can, cancel, clean
    'delete_forever_rounded':
        0xf695, // [round] action — archive, bin, can, cancel, clean
    'delete_forever_sharp':
        0xe8b6, // [sharp] action — archive, bin, can, cancel, clean
    'delete_outline': 0xe1bb, // action — basket, bin, can, cancel, clean up
    'delete_outline_outlined':
        0xefa9, // [outline] action — basket, bin, can, cancel, clean up
    'delete_outline_rounded':
        0xf696, // [round] action — basket, bin, can, cancel, clean up
    'delete_outline_sharp':
        0xe8b7, // [sharp] action — basket, bin, can, cancel, clean up
    'delete_outlined':
        0xefaa, // [outline] action — basket, bin, can, cancel, clean up
    'delete_rounded':
        0xf697, // [round] action — basket, bin, can, cancel, clean up
    'delete_sharp':
        0xe8b8, // [sharp] action — basket, bin, can, cancel, clean up
    'delete_sweep':
        0xe1bc, // content — batch delete, batch remove, bin, broom, bulk delete
    'delete_sweep_outlined':
        0xefab, // [outline] content — batch delete, batch remove, bin, broom, bulk delete
    'delete_sweep_rounded':
        0xf698, // [round] content — batch delete, batch remove, bin, broom, bulk delete
    'delete_sweep_sharp':
        0xe8b9, // [sharp] content — batch delete, batch remove, bin, broom, bulk delete
    'delivery_dining':
        0xe1bd, // maps — buy, commerce, courier, delivery, dining
    'delivery_dining_outlined':
        0xefac, // [outline] maps — buy, commerce, courier, delivery, dining
    'delivery_dining_rounded':
        0xf699, // [round] maps — buy, commerce, courier, delivery, dining
    'delivery_dining_sharp':
        0xe8ba, // [sharp] maps — buy, commerce, courier, delivery, dining
    'density_large':
        0xf04e9, // action — bars, block, collapse, density, density large
    'density_large_outlined':
        0xf05e3, // [outline] action — bars, block, collapse, density, density large
    'density_large_rounded':
        0xf0302, // [round] action — bars, block, collapse, density, density large
    'density_large_sharp':
        0xf03f5, // [sharp] action — bars, block, collapse, density, density large
    'density_medium':
        0xf04ea, // action — adjust, arrangement, bars, compact, content density
    'density_medium_outlined':
        0xf05e4, // [outline] action — adjust, arrangement, bars, compact, content density
    'density_medium_rounded':
        0xf0303, // [round] action — adjust, arrangement, bars, compact, content density
    'density_medium_sharp':
        0xf03f6, // [sharp] action — adjust, arrangement, bars, compact, content density
    'density_small':
        0xf04eb, // action — compact, condensed, dense, density, horizontal
    'density_small_outlined':
        0xf05e5, // [outline] action — compact, condensed, dense, density, horizontal
    'density_small_rounded':
        0xf0304, // [round] action — compact, condensed, dense, density, horizontal
    'density_small_sharp':
        0xf03f7, // [sharp] action — compact, condensed, dense, density, horizontal
    'departure_board':
        0xe1be, // maps — airport, arrival board, arrivals, automobile, board
    'departure_board_outlined':
        0xefad, // [outline] maps — airport, arrival board, arrivals, automobile, board
    'departure_board_rounded':
        0xf69a, // [round] maps — airport, arrival board, arrivals, automobile, board
    'departure_board_sharp':
        0xe8bb, // [sharp] maps — airport, arrival board, arrivals, automobile, board
    'description':
        0xe1bf, // action — article, content, description, details, doc
    'description_outlined':
        0xefae, // [outline] action — article, content, description, details, doc
    'description_rounded':
        0xf69b, // [round] action — article, content, description, details, doc
    'description_sharp':
        0xe8bc, // [sharp] action — article, content, description, details, doc
    'deselect': 0xf04ec, // content — all, blank, box, cancel, checkbox
    'deselect_outlined':
        0xf05e6, // [outline] content — all, blank, box, cancel, checkbox
    'deselect_rounded':
        0xf0305, // [round] content — all, blank, box, cancel, checkbox
    'deselect_sharp':
        0xf03f8, // [sharp] content — all, blank, box, cancel, checkbox
    'design_services':
        0xe1c0, // maps — architecture, art, build, compose, create
    'design_services_outlined':
        0xefaf, // [outline] maps — architecture, art, build, compose, create
    'design_services_rounded':
        0xf69c, // [round] maps — architecture, art, build, compose, create
    'design_services_sharp':
        0xe8bd, // [sharp] maps — architecture, art, build, compose, create
    'desk':
        0xf079a, // places — business, computer desk, desk, education, equipment
    'desk_outlined':
        0xf06ea, // [outline] places — business, computer desk, desk, education, equipment
    'desk_rounded':
        0xf07f2, // [round] places — business, computer desk, desk, education, equipment
    'desk_sharp':
        0xf0742, // [sharp] places — business, computer desk, desk, education, equipment
    'desktop_access_disabled':
        0xe1c1, // communication — Android, OS, access, barring, blocked
    'desktop_access_disabled_outlined':
        0xefb0, // [outline] communication — Android, OS, access, barring, blocked
    'desktop_access_disabled_rounded':
        0xf69d, // [round] communication — Android, OS, access, barring, blocked
    'desktop_access_disabled_sharp':
        0xe8be, // [sharp] communication — Android, OS, access, barring, blocked
    'desktop_mac': 0xe1c2, // hardware — Android, OS, all-in-one, base, chrome
    'desktop_mac_outlined':
        0xefb1, // [outline] hardware — Android, OS, all-in-one, base, chrome
    'desktop_mac_rounded':
        0xf69e, // [round] hardware — Android, OS, all-in-one, base, chrome
    'desktop_mac_sharp':
        0xe8bf, // [sharp] hardware — Android, OS, all-in-one, base, chrome
    'desktop_windows': 0xe1c3, // hardware — Android, OS, cast, chrome, computer
    'desktop_windows_outlined':
        0xefb2, // [outline] hardware — Android, OS, cast, chrome, computer
    'desktop_windows_rounded':
        0xf69f, // [round] hardware — Android, OS, cast, chrome, computer
    'desktop_windows_sharp':
        0xe8c0, // [sharp] hardware — Android, OS, cast, chrome, computer
    'details': 0xe1c4, // image — additional, detail, details, dots, edit
    'details_outlined':
        0xefb3, // [outline] image — additional, detail, details, dots, edit
    'details_rounded':
        0xf6a0, // [round] image — additional, detail, details, dots, edit
    'details_sharp':
        0xe8c1, // [sharp] image — additional, detail, details, dots, edit
    'developer_board':
        0xe1c5, // hardware — board, build, chip, circuit board, code
    'developer_board_off':
        0xe1c6, // hardware — board, chip, circuit, circuit board, computer
    'developer_board_off_outlined':
        0xefb4, // [outline] hardware — board, chip, circuit, circuit board, computer
    'developer_board_off_rounded':
        0xf6a1, // [round] hardware — board, chip, circuit, circuit board, computer
    'developer_board_off_sharp':
        0xe8c2, // [sharp] hardware — board, chip, circuit, circuit board, computer
    'developer_board_outlined':
        0xefb5, // [outline] hardware — board, build, chip, circuit board, code
    'developer_board_rounded':
        0xf6a2, // [round] hardware — board, build, chip, circuit board, code
    'developer_board_sharp':
        0xe8c3, // [sharp] hardware — board, build, chip, circuit board, code
    'developer_mode':
        0xe1c7, // device — Android, OS, advanced settings, angle bracket, bracket
    'developer_mode_outlined':
        0xefb6, // [outline] device — Android, OS, advanced settings, angle bracket, bracket
    'developer_mode_rounded':
        0xf6a3, // [round] device — Android, OS, advanced settings, angle bracket, bracket
    'developer_mode_sharp':
        0xe8c4, // [sharp] device — Android, OS, advanced settings, angle bracket, bracket
    'device_hub':
        0xe1c8, // hardware — Android, OS, architecture, center, central point
    'device_hub_outlined':
        0xefb7, // [outline] hardware — Android, OS, architecture, center, central point
    'device_hub_rounded':
        0xf6a4, // [round] hardware — Android, OS, architecture, center, central point
    'device_hub_sharp':
        0xe8c5, // [sharp] hardware — Android, OS, architecture, center, central point
    'device_thermostat':
        0xe1c9, // device — adjust, automation, celsius, circle, climate
    'device_thermostat_outlined':
        0xefb8, // [outline] device — adjust, automation, celsius, circle, climate
    'device_thermostat_rounded':
        0xf6a5, // [round] device — adjust, automation, celsius, circle, climate
    'device_thermostat_sharp':
        0xe8c6, // [sharp] device — adjust, automation, celsius, circle, climate
    'device_unknown': 0xe1ca, // hardware — ?, Android, OS, assistance, cell
    'device_unknown_outlined':
        0xefb9, // [outline] hardware — ?, Android, OS, assistance, cell
    'device_unknown_rounded':
        0xf6a6, // [round] hardware — ?, Android, OS, assistance, cell
    'device_unknown_sharp':
        0xe8c7, // [sharp] hardware — ?, Android, OS, assistance, cell
    'devices': 0xe1cb, // device — Android, OS, cast, communication, computer
    'devices_fold': 0xf079b, // device — Android, OS, cell, closed, computer
    'devices_fold_outlined':
        0xf06eb, // [outline] device — Android, OS, cell, closed, computer
    'devices_fold_rounded':
        0xf07f3, // [round] device — Android, OS, cell, closed, computer
    'devices_fold_sharp':
        0xf0743, // [sharp] device — Android, OS, cell, closed, computer
    'devices_other': 0xe1cc, // hardware — Android, OS, ar, audio, casting
    'devices_other_outlined':
        0xefba, // [outline] hardware — Android, OS, ar, audio, casting
    'devices_other_rounded':
        0xf6a7, // [round] hardware — Android, OS, ar, audio, casting
    'devices_other_sharp':
        0xe8c8, // [sharp] hardware — Android, OS, ar, audio, casting
    'devices_outlined':
        0xefbb, // [outline] device — Android, OS, cast, communication, computer
    'devices_rounded':
        0xf6a8, // [round] device — Android, OS, cast, communication, computer
    'devices_sharp':
        0xe8c9, // [sharp] device — Android, OS, cast, communication, computer
    'dew_point':
        0xf0859, // social — air, atmosphere, atmospheric, climate, condensation
    'dialer_sip':
        0xe1cd, // communication — alphabet, call, cell, character, communication
    'dialer_sip_outlined':
        0xefbc, // [outline] communication — alphabet, call, cell, character, communication
    'dialer_sip_rounded':
        0xf6a9, // [round] communication — alphabet, call, cell, character, communication
    'dialer_sip_sharp':
        0xe8ca, // [sharp] communication — alphabet, call, cell, character, communication
    'dialpad':
        0xe1ce, // communication — call, communication, contact, device, dial
    'dialpad_outlined':
        0xefbd, // [outline] communication — call, communication, contact, device, dial
    'dialpad_rounded':
        0xf6aa, // [round] communication — call, communication, contact, device, dial
    'dialpad_sharp':
        0xe8cb, // [sharp] communication — call, communication, contact, device, dial
    'diamond': 0xf04ed, // maps — award, brilliant, clean, crystal, cut
    'diamond_outlined':
        0xf05e7, // [outline] maps — award, brilliant, clean, crystal, cut
    'diamond_rounded':
        0xf0306, // [round] maps — award, brilliant, clean, crystal, cut
    'diamond_sharp':
        0xf03f9, // [sharp] maps — award, brilliant, clean, crystal, cut
    'difference': 0xf04ee, // file — choice, compare, content, contrast, copy
    'difference_outlined':
        0xf05e8, // [outline] file — choice, compare, content, contrast, copy
    'difference_rounded':
        0xf0307, // [round] file — choice, compare, content, contrast, copy
    'difference_sharp':
        0xf03fa, // [sharp] file — choice, compare, content, contrast, copy
    'dining': 0xe1cf, // search — beverage, bistro, breakfast, cafe, cafeteria
    'dining_outlined':
        0xefbe, // [outline] search — beverage, bistro, breakfast, cafe, cafeteria
    'dining_rounded':
        0xf6ab, // [round] search — beverage, bistro, breakfast, cafe, cafeteria
    'dining_sharp':
        0xe8cc, // [sharp] search — beverage, bistro, breakfast, cafe, cafeteria
    'dinner_dining':
        0xe1d0, // maps — beverage, breakfast, cafe, cooking, cuisine
    'dinner_dining_outlined':
        0xefbf, // [outline] maps — beverage, breakfast, cafe, cooking, cuisine
    'dinner_dining_rounded':
        0xf6ac, // [round] maps — beverage, breakfast, cafe, cooking, cuisine
    'dinner_dining_sharp':
        0xe8cd, // [sharp] maps — beverage, breakfast, cafe, cooking, cuisine
    'directions': 0xe1d1, // maps — address, arrow, compass, course, destination
    'directions_bike':
        0xe1d2, // maps — activity, bicycle, bike, cycling, direction
    'directions_bike_outlined':
        0xefc0, // [outline] maps — activity, bicycle, bike, cycling, direction
    'directions_bike_rounded':
        0xf6ad, // [round] maps — activity, bicycle, bike, cycling, direction
    'directions_bike_sharp':
        0xe8ce, // [sharp] maps — activity, bicycle, bike, cycling, direction
    'directions_boat': 0xe1d3, // maps — automobile, boat, boating, car, cars
    'directions_boat_filled':
        0xe1d4, // maps — automobile, boat, boating, car, cars
    'directions_boat_filled_outlined':
        0xefc1, // [outline] maps — automobile, boat, boating, car, cars
    'directions_boat_filled_rounded':
        0xf6ae, // [round] maps — automobile, boat, boating, car, cars
    'directions_boat_filled_sharp':
        0xe8cf, // [sharp] maps — automobile, boat, boating, car, cars
    'directions_boat_outlined':
        0xefc2, // [outline] maps — automobile, boat, boating, car, cars
    'directions_boat_rounded':
        0xf6af, // [round] maps — automobile, boat, boating, car, cars
    'directions_boat_sharp':
        0xe8d0, // [sharp] maps — automobile, boat, boating, car, cars
    'directions_bus': 0xe1d5, // maps — automobile, bus, car, cars, commute
    'directions_bus_filled':
        0xe1d6, // maps — automobile, bus, car, cars, commute
    'directions_bus_filled_outlined':
        0xefc3, // [outline] maps — automobile, bus, car, cars, commute
    'directions_bus_filled_rounded':
        0xf6b0, // [round] maps — automobile, bus, car, cars, commute
    'directions_bus_filled_sharp':
        0xe8d1, // [sharp] maps — automobile, bus, car, cars, commute
    'directions_bus_outlined':
        0xefc4, // [outline] maps — automobile, bus, car, cars, commute
    'directions_bus_rounded':
        0xf6b1, // [round] maps — automobile, bus, car, cars, commute
    'directions_bus_sharp':
        0xe8d2, // [sharp] maps — automobile, bus, car, cars, commute
    'directions_car':
        0xe1d7, // maps — auto, automobile, automotive, car, car symbol
    'directions_car_filled':
        0xe1d8, // maps — auto, automobile, automotive, car, car symbol
    'directions_car_filled_outlined':
        0xefc5, // [outline] maps — auto, automobile, automotive, car, car symbol
    'directions_car_filled_rounded':
        0xf6b2, // [round] maps — auto, automobile, automotive, car, car symbol
    'directions_car_filled_sharp':
        0xe8d3, // [sharp] maps — auto, automobile, automotive, car, car symbol
    'directions_car_outlined':
        0xefc6, // [outline] maps — auto, automobile, automotive, car, car symbol
    'directions_car_rounded':
        0xf6b3, // [round] maps — auto, automobile, automotive, car, car symbol
    'directions_car_sharp':
        0xe8d4, // [sharp] maps — auto, automobile, automotive, car, car symbol
    'directions_ferry': 0xe1d3, // maps — automobile, boat, boating, car, cars
    'directions_ferry_outlined':
        0xefc2, // [outline] maps — automobile, boat, boating, car, cars
    'directions_ferry_rounded':
        0xf6af, // [round] maps — automobile, boat, boating, car, cars
    'directions_ferry_sharp':
        0xe8d0, // [sharp] maps — automobile, boat, boating, car, cars
    'directions_off':
        0xe1d9, // notification — arrow, blocked, cancel, circle with slash, clear route
    'directions_off_outlined':
        0xefc7, // [outline] notification — arrow, blocked, cancel, circle with slash, clear route
    'directions_off_rounded':
        0xf6b4, // [round] notification — arrow, blocked, cancel, circle with slash, clear route
    'directions_off_sharp':
        0xe8d5, // [sharp] notification — arrow, blocked, cancel, circle with slash, clear route
    'directions_outlined':
        0xefc8, // [outline] maps — address, arrow, compass, course, destination
    'directions_railway':
        0xe1da, // maps — automobile, car, cars, commuter, commuting
    'directions_railway_filled':
        0xe1db, // maps — automobile, car, cars, commuter, commuting
    'directions_railway_filled_outlined':
        0xefc9, // [outline] maps — automobile, car, cars, commuter, commuting
    'directions_railway_filled_rounded':
        0xf6b5, // [round] maps — automobile, car, cars, commuter, commuting
    'directions_railway_filled_sharp':
        0xe8d6, // [sharp] maps — automobile, car, cars, commuter, commuting
    'directions_railway_outlined':
        0xefca, // [outline] maps — automobile, car, cars, commuter, commuting
    'directions_railway_rounded':
        0xf6b6, // [round] maps — automobile, car, cars, commuter, commuting
    'directions_railway_sharp':
        0xe8d7, // [sharp] maps — automobile, car, cars, commuter, commuting
    'directions_rounded':
        0xf6b7, // [round] maps — address, arrow, compass, course, destination
    'directions_run':
        0xe1dc, // maps — activity, athlete, beginning, body, destination
    'directions_run_outlined':
        0xefcb, // [outline] maps — activity, athlete, beginning, body, destination
    'directions_run_rounded':
        0xf6b8, // [round] maps — activity, athlete, beginning, body, destination
    'directions_run_sharp':
        0xe8d8, // [sharp] maps — activity, athlete, beginning, body, destination
    'directions_sharp':
        0xe8d9, // [sharp] maps — address, arrow, compass, course, destination
    'directions_subway': 0xe1dd, // maps — automobile, car, cars, city, commute
    'directions_subway_filled':
        0xe1de, // maps — automobile, car, cars, city, commute
    'directions_subway_filled_outlined':
        0xefcc, // [outline] maps — automobile, car, cars, city, commute
    'directions_subway_filled_rounded':
        0xf6b9, // [round] maps — automobile, car, cars, city, commute
    'directions_subway_filled_sharp':
        0xe8da, // [sharp] maps — automobile, car, cars, city, commute
    'directions_subway_outlined':
        0xefcd, // [outline] maps — automobile, car, cars, city, commute
    'directions_subway_rounded':
        0xf6ba, // [round] maps — automobile, car, cars, city, commute
    'directions_subway_sharp':
        0xe8db, // [sharp] maps — automobile, car, cars, city, commute
    'directions_train': 0xe1da,
    'directions_train_outlined': 0xefca,
    'directions_train_rounded': 0xf6b6,
    'directions_train_sharp': 0xe8d7,
    'directions_transit': 0xe1df, // maps — automobile, car, cars, city, commute
    'directions_transit_filled':
        0xe1e0, // maps — automobile, car, cars, city, commute
    'directions_transit_filled_outlined':
        0xefce, // [outline] maps — automobile, car, cars, city, commute
    'directions_transit_filled_rounded':
        0xf6bb, // [round] maps — automobile, car, cars, city, commute
    'directions_transit_filled_sharp':
        0xe8dc, // [sharp] maps — automobile, car, cars, city, commute
    'directions_transit_outlined':
        0xefcf, // [outline] maps — automobile, car, cars, city, commute
    'directions_transit_rounded':
        0xf6bc, // [round] maps — automobile, car, cars, city, commute
    'directions_transit_sharp':
        0xe8dd, // [sharp] maps — automobile, car, cars, city, commute
    'directions_walk':
        0xe1e1, // maps — activity, assist, body, direction, directions
    'directions_walk_outlined':
        0xefd0, // [outline] maps — activity, assist, body, direction, directions
    'directions_walk_rounded':
        0xf6bd, // [round] maps — activity, assist, body, direction, directions
    'directions_walk_sharp':
        0xe8de, // [sharp] maps — activity, assist, body, direction, directions
    'dirty_lens': 0xe1e2, // image — alert, blurred, camera, capture, circle
    'dirty_lens_outlined':
        0xefd1, // [outline] image — alert, blurred, camera, capture, circle
    'dirty_lens_rounded':
        0xf6be, // [round] image — alert, blurred, camera, capture, circle
    'dirty_lens_sharp':
        0xe8df, // [sharp] image — alert, blurred, camera, capture, circle
    'disabled_by_default':
        0xe1e3, // action — access denied, alert, blocked, box, by
    'disabled_by_default_outlined':
        0xefd2, // [outline] action — access denied, alert, blocked, box, by
    'disabled_by_default_rounded':
        0xf6bf, // [round] action — access denied, alert, blocked, box, by
    'disabled_by_default_sharp':
        0xe8e0, // [sharp] action — access denied, alert, blocked, box, by
    'disabled_visible':
        0xf04ef, // action — accessibility, block view, cancel, close, disabled
    'disabled_visible_outlined':
        0xf05e9, // [outline] action — accessibility, block view, cancel, close, disabled
    'disabled_visible_rounded':
        0xf0308, // [round] action — accessibility, block view, cancel, close, disabled
    'disabled_visible_sharp':
        0xf03fb, // [sharp] action — accessibility, block view, cancel, close, disabled
    'disc_full': 0xe1e4, // notification — !, album, alert, analog, attention
    'disc_full_outlined':
        0xefd3, // [outline] notification — !, album, alert, analog, attention
    'disc_full_rounded':
        0xf6c0, // [round] notification — !, album, alert, analog, attention
    'disc_full_sharp':
        0xe8e1, // [sharp] notification — !, album, alert, analog, attention
    'discord': 0xf04f0, // brand logo
    'discord_outlined': 0xf05ea, // [outline] brand logo
    'discord_rounded': 0xf0309, // [round] brand logo
    'discord_sharp': 0xf03fc, // [sharp] brand logo
    'discount': 0xf06bd, // device
    'discount_outlined': 0xf06a3, // [outline] device
    'discount_rounded': 0xf06ca, // [round] device
    'discount_sharp': 0xf06b0, // [sharp] device
    'display_settings':
        0xf04f1, // action — Android, OS, adjustments, brightness, change
    'display_settings_outlined':
        0xf05eb, // [outline] action — Android, OS, adjustments, brightness, change
    'display_settings_rounded':
        0xf030a, // [round] action — Android, OS, adjustments, brightness, change
    'display_settings_sharp':
        0xf03fd, // [sharp] action — Android, OS, adjustments, brightness, change
    'diversity_1':
        0xf085a, // social — account, avatar, characters, circle, collaboration
    'diversity_1_outlined':
        0xf089f, // [outline] social — account, avatar, characters, circle, collaboration
    'diversity_1_rounded':
        0xf0881, // [round] social — account, avatar, characters, circle, collaboration
    'diversity_1_sharp':
        0xf0838, // [sharp] social — account, avatar, characters, circle, collaboration
    'diversity_2':
        0xf085b, // social — avatars, collaboration, committee, community, diverse
    'diversity_2_outlined':
        0xf08a0, // [outline] social — avatars, collaboration, committee, community, diverse
    'diversity_2_rounded':
        0xf0882, // [round] social — avatars, collaboration, committee, community, diverse
    'diversity_2_sharp':
        0xf0839, // [sharp] social — avatars, collaboration, committee, community, diverse
    'diversity_3':
        0xf085c, // social — committee, community, crowd, culture, different
    'diversity_3_outlined':
        0xf08a1, // [outline] social — committee, community, crowd, culture, different
    'diversity_3_rounded':
        0xf0883, // [round] social — committee, community, crowd, culture, different
    'diversity_3_sharp':
        0xf083a, // [sharp] social — committee, community, crowd, culture, different
    'dnd_forwardslash': 0xe1eb,
    'dnd_forwardslash_outlined': 0xefd9,
    'dnd_forwardslash_rounded': 0xf6c6,
    'dnd_forwardslash_sharp': 0xe8e7,
    'dns': 0xe1e5, // action — abstract, address, administration, bars, circles
    'dns_outlined':
        0xefd4, // [outline] action — abstract, address, administration, bars, circles
    'dns_rounded':
        0xf6c1, // [round] action — abstract, address, administration, bars, circles
    'dns_sharp':
        0xe8e2, // [sharp] action — abstract, address, administration, bars, circles
    'do_disturb': 0xe1e6, // notification — alert, ban, block, cancel, circle
    'do_disturb_alt':
        0xe1e7, // notification — alert, bell, block, cancel, circle
    'do_disturb_alt_outlined':
        0xefd5, // [outline] notification — alert, bell, block, cancel, circle
    'do_disturb_alt_rounded':
        0xf6c2, // [round] notification — alert, bell, block, cancel, circle
    'do_disturb_alt_sharp':
        0xe8e3, // [sharp] notification — alert, bell, block, cancel, circle
    'do_disturb_off':
        0xe1e8, // notification — accessibility, active, allow notifications, available, bar
    'do_disturb_off_outlined':
        0xefd6, // [outline] notification — accessibility, active, allow notifications, available, bar
    'do_disturb_off_rounded':
        0xf6c3, // [round] notification — accessibility, active, allow notifications, available, bar
    'do_disturb_off_sharp':
        0xe8e4, // [sharp] notification — accessibility, active, allow notifications, available, bar
    'do_disturb_on':
        0xe1e9, // notification — alert, ban, block, cancel, caution
    'do_disturb_on_outlined':
        0xefd7, // [outline] notification — alert, ban, block, cancel, caution
    'do_disturb_on_rounded':
        0xf6c4, // [round] notification — alert, ban, block, cancel, caution
    'do_disturb_on_sharp':
        0xe8e5, // [sharp] notification — alert, ban, block, cancel, caution
    'do_disturb_outlined':
        0xefd8, // [outline] notification — alert, ban, block, cancel, circle
    'do_disturb_rounded':
        0xf6c5, // [round] notification — alert, ban, block, cancel, circle
    'do_disturb_sharp':
        0xe8e6, // [sharp] notification — alert, ban, block, cancel, circle
    'do_not_disturb':
        0xe1ea, // notification — alert, bell, block, cancel, circle
    'do_not_disturb_alt':
        0xe1eb, // notification — alert, ban, block, cancel, circle
    'do_not_disturb_alt_outlined':
        0xefd9, // [outline] notification — alert, ban, block, cancel, circle
    'do_not_disturb_alt_rounded':
        0xf6c6, // [round] notification — alert, ban, block, cancel, circle
    'do_not_disturb_alt_sharp':
        0xe8e7, // [sharp] notification — alert, ban, block, cancel, circle
    'do_not_disturb_off':
        0xe1ec, // notification — accessibility, active, allow notifications, available, bar
    'do_not_disturb_off_outlined':
        0xefda, // [outline] notification — accessibility, active, allow notifications, available, bar
    'do_not_disturb_off_rounded':
        0xf6c7, // [round] notification — accessibility, active, allow notifications, available, bar
    'do_not_disturb_off_sharp':
        0xe8e8, // [sharp] notification — accessibility, active, allow notifications, available, bar
    'do_not_disturb_on':
        0xe1ed, // notification — alert, ban, block, cancel, caution
    'do_not_disturb_on_outlined':
        0xefdb, // [outline] notification — alert, ban, block, cancel, caution
    'do_not_disturb_on_rounded':
        0xf6c8, // [round] notification — alert, ban, block, cancel, caution
    'do_not_disturb_on_sharp':
        0xe8e9, // [sharp] notification — alert, ban, block, cancel, caution
    'do_not_disturb_on_total_silence':
        0xe1ee, // device — alert, ban, bell, blocked, busy
    'do_not_disturb_on_total_silence_outlined':
        0xefdc, // [outline] device — alert, ban, bell, blocked, busy
    'do_not_disturb_on_total_silence_rounded':
        0xf6c9, // [round] device — alert, ban, bell, blocked, busy
    'do_not_disturb_on_total_silence_sharp':
        0xe8ea, // [sharp] device — alert, ban, bell, blocked, busy
    'do_not_disturb_outlined':
        0xefdd, // [outline] notification — alert, bell, block, cancel, circle
    'do_not_disturb_rounded':
        0xf6ca, // [round] notification — alert, bell, block, cancel, circle
    'do_not_disturb_sharp':
        0xe8eb, // [sharp] notification — alert, bell, block, cancel, circle
    'do_not_step': 0xe1ef, // places — alert, boot, boundary, caution, circle
    'do_not_step_outlined':
        0xefde, // [outline] places — alert, boot, boundary, caution, circle
    'do_not_step_rounded':
        0xf6cb, // [round] places — alert, boot, boundary, caution, circle
    'do_not_step_sharp':
        0xe8ec, // [sharp] places — alert, boot, boundary, caution, circle
    'do_not_touch':
        0xe1f0, // places — access denied, barrier, beware, blocked, caution
    'do_not_touch_outlined':
        0xefdf, // [outline] places — access denied, barrier, beware, blocked, caution
    'do_not_touch_rounded':
        0xf6cc, // [round] places — access denied, barrier, beware, blocked, caution
    'do_not_touch_sharp':
        0xe8ed, // [sharp] places — access denied, barrier, beware, blocked, caution
    'dock': 0xe1f1, // hardware — Android, OS, accessory, base, cell
    'dock_outlined':
        0xefe0, // [outline] hardware — Android, OS, accessory, base, cell
    'dock_rounded':
        0xf6cd, // [round] hardware — Android, OS, accessory, base, cell
    'dock_sharp':
        0xe8ee, // [sharp] hardware — Android, OS, accessory, base, cell
    'document_scanner':
        0xe1f2, // communication — article, business, camera, capture, corners
    'document_scanner_outlined':
        0xefe1, // [outline] communication — article, business, camera, capture, corners
    'document_scanner_rounded':
        0xf6ce, // [round] communication — article, business, camera, capture, corners
    'document_scanner_sharp':
        0xe8ef, // [sharp] communication — article, business, camera, capture, corners
    'domain':
        0xe1f3, // social — address, apartment, architecture, building, business
    'domain_add': 0xf04f2, // social — +, add, add domain, add site, add website
    'domain_add_outlined':
        0xf05ec, // [outline] social — +, add, add domain, add site, add website
    'domain_add_rounded':
        0xf030b, // [round] social — +, add, add domain, add site, add website
    'domain_add_sharp':
        0xf03fe, // [sharp] social — +, add, add domain, add site, add website
    'domain_disabled':
        0xe1f4, // communication — access denied, apartment, architecture, blocked, building
    'domain_disabled_outlined':
        0xefe2, // [outline] communication — access denied, apartment, architecture, blocked, building
    'domain_disabled_rounded':
        0xf6cf, // [round] communication — access denied, apartment, architecture, blocked, building
    'domain_disabled_sharp':
        0xe8f0, // [sharp] communication — access denied, apartment, architecture, blocked, building
    'domain_outlined':
        0xefe3, // [outline] social — address, apartment, architecture, building, business
    'domain_rounded':
        0xf6d0, // [round] social — address, apartment, architecture, building, business
    'domain_sharp':
        0xe8f1, // [sharp] social — address, apartment, architecture, building, business
    'domain_verification':
        0xe1f5, // communication — access, application desktop, approve, approved, authenticated
    'domain_verification_outlined':
        0xefe4, // [outline] communication — access, application desktop, approve, approved, authenticated
    'domain_verification_rounded':
        0xf6d1, // [round] communication — access, application desktop, approve, approved, authenticated
    'domain_verification_sharp':
        0xe8f2, // [sharp] communication — access, application desktop, approve, approved, authenticated
    'done':
        0xe1f6, // action — accepted, accomplished, acknowledgement, agree, approval
    'done_all':
        0xe1f7, // action — achievement, all, all done, approval, approve
    'done_all_outlined':
        0xefe5, // [outline] action — achievement, all, all done, approval, approve
    'done_all_rounded':
        0xf6d2, // [round] action — achievement, all, all done, approval, approve
    'done_all_sharp':
        0xe8f3, // [sharp] action — achievement, all, all done, approval, approve
    'done_outline':
        0xe1f8, // action — accepted, achievement, agreement, all, approval
    'done_outline_outlined':
        0xefe6, // [outline] action — accepted, achievement, agreement, all, approval
    'done_outline_rounded':
        0xf6d3, // [round] action — accepted, achievement, agreement, all, approval
    'done_outline_sharp':
        0xe8f4, // [sharp] action — accepted, achievement, agreement, all, approval
    'done_outlined':
        0xefe7, // [outline] action — accepted, accomplished, acknowledgement, agree, approval
    'done_rounded':
        0xf6d4, // [round] action — accepted, accomplished, acknowledgement, agree, approval
    'done_sharp':
        0xe8f5, // [sharp] action — accepted, accomplished, acknowledgement, agree, approval
    'donut_large':
        0xe1f9, // action — activity, activity indicator, analytics, chart, circle
    'donut_large_outlined':
        0xefe8, // [outline] action — activity, activity indicator, analytics, chart, circle
    'donut_large_rounded':
        0xf6d5, // [round] action — activity, activity indicator, analytics, chart, circle
    'donut_large_sharp':
        0xe8f6, // [sharp] action — activity, activity indicator, analytics, chart, circle
    'donut_small':
        0xe1fa, // action — analytics, chart, circle, circular, dashboard
    'donut_small_outlined':
        0xefe9, // [outline] action — analytics, chart, circle, circular, dashboard
    'donut_small_rounded':
        0xf6d6, // [round] action — analytics, chart, circle, circular, dashboard
    'donut_small_sharp':
        0xe8f7, // [sharp] action — analytics, chart, circle, circular, dashboard
    'door_back_door': 0xe1fb,
    'door_back_door_outlined': 0xefea,
    'door_back_door_rounded': 0xf6d7,
    'door_back_door_sharp': 0xe8f8,
    'door_front_door': 0xe1fc,
    'door_front_door_outlined': 0xefeb,
    'door_front_door_rounded': 0xf6d8,
    'door_front_door_sharp': 0xe8f9,
    'door_sliding':
        0xe1fd, // search — access, architecture, auto, automatic, barrier
    'door_sliding_outlined':
        0xefec, // [outline] search — access, architecture, auto, automatic, barrier
    'door_sliding_rounded':
        0xf6d9, // [round] search — access, architecture, auto, automatic, barrier
    'door_sliding_sharp':
        0xe8fa, // [sharp] search — access, architecture, auto, automatic, barrier
    'doorbell': 0xe1fe, // search — alarm, alert, bell, chime, door
    'doorbell_outlined':
        0xefed, // [outline] search — alarm, alert, bell, chime, door
    'doorbell_rounded':
        0xf6da, // [round] search — alarm, alert, bell, chime, door
    'doorbell_sharp':
        0xe8fb, // [sharp] search — alarm, alert, bell, chime, door
    'double_arrow':
        0xe1ff, // navigation — abstract, arrow, arrowheads, arrows, bidirectional
    'double_arrow_outlined':
        0xefee, // [outline] navigation — abstract, arrow, arrowheads, arrows, bidirectional
    'double_arrow_rounded':
        0xf6db, // [round] navigation — abstract, arrow, arrowheads, arrows, bidirectional
    'double_arrow_sharp':
        0xe8fc, // [sharp] navigation — abstract, arrow, arrowheads, arrows, bidirectional
    'downhill_skiing':
        0xe200, // social — abstract, activity, athlete, athletic, body
    'downhill_skiing_outlined':
        0xefef, // [outline] social — abstract, activity, athlete, athletic, body
    'downhill_skiing_rounded':
        0xf6dc, // [round] social — abstract, activity, athlete, athletic, body
    'downhill_skiing_sharp':
        0xe8fd, // [sharp] social — abstract, activity, athlete, athletic, body
    'download': 0xe201, // file — acquire, archive, arrow, bar, cloud
    'download_done':
        0xe202, // file — arrow, arrow and check, arrows, check, checkmark
    'download_done_outlined':
        0xeff0, // [outline] file — arrow, arrow and check, arrows, check, checkmark
    'download_done_rounded':
        0xf6dd, // [round] file — arrow, arrow and check, arrows, check, checkmark
    'download_done_sharp':
        0xe8fe, // [sharp] file — arrow, arrow and check, arrows, check, checkmark
    'download_for_offline':
        0xe203, // file — access, arrow, available offline, backup, caching
    'download_for_offline_outlined':
        0xeff1, // [outline] file — access, arrow, available offline, backup, caching
    'download_for_offline_rounded':
        0xf6de, // [round] file — access, arrow, available offline, backup, caching
    'download_for_offline_sharp':
        0xe8ff, // [sharp] file — access, arrow, available offline, backup, caching
    'download_outlined':
        0xeff2, // [outline] file — acquire, archive, arrow, bar, cloud
    'download_rounded':
        0xf6df, // [round] file — acquire, archive, arrow, bar, cloud
    'download_sharp':
        0xe900, // [sharp] file — acquire, archive, arrow, bar, cloud
    'downloading': 0xe204, // file — arrow, circle, cloud, cloud download, down
    'downloading_outlined':
        0xeff3, // [outline] file — arrow, circle, cloud, cloud download, down
    'downloading_rounded':
        0xf6e0, // [round] file — arrow, circle, cloud, cloud download, down
    'downloading_sharp':
        0xe901, // [sharp] file — arrow, circle, cloud, cloud download, down
    'drafts':
        0xe205, // content — archive, communication, composing, creating, document
    'drafts_outlined':
        0xeff4, // [outline] content — archive, communication, composing, creating, document
    'drafts_rounded':
        0xf6e1, // [round] content — archive, communication, composing, creating, document
    'drafts_sharp':
        0xe902, // [sharp] content — archive, communication, composing, creating, document
    'drag_handle': 0xe206, // editor — bars, design, drag, grip, handle
    'drag_handle_outlined':
        0xeff5, // [outline] editor — bars, design, drag, grip, handle
    'drag_handle_rounded':
        0xf6e2, // [round] editor — bars, design, drag, grip, handle
    'drag_handle_sharp':
        0xe903, // [sharp] editor — bars, design, drag, grip, handle
    'drag_indicator': 0xe207, // action — circles, column, design, dots, drag
    'drag_indicator_outlined':
        0xeff6, // [outline] action — circles, column, design, dots, drag
    'drag_indicator_rounded':
        0xf6e3, // [round] action — circles, column, design, dots, drag
    'drag_indicator_sharp':
        0xe904, // [sharp] action — circles, column, design, dots, drag
    'draw': 0xf04f3, // editor — art, artist, compose, crayon, create
    'draw_outlined':
        0xf05ed, // [outline] editor — art, artist, compose, crayon, create
    'draw_rounded':
        0xf030c, // [round] editor — art, artist, compose, crayon, create
    'draw_sharp':
        0xf03ff, // [sharp] editor — art, artist, compose, crayon, create
    'drive_eta':
        0xe208, // notification — auto, automobile, automotive, car, car symbol
    'drive_eta_outlined':
        0xeff7, // [outline] notification — auto, automobile, automotive, car, car symbol
    'drive_eta_rounded':
        0xf6e4, // [round] notification — auto, automobile, automotive, car, car symbol
    'drive_eta_sharp':
        0xe905, // [sharp] notification — auto, automobile, automotive, car, car symbol
    'drive_file_move': 0xe209, // file — arrange, arrow, cloud, copy, deliver
    'drive_file_move_outline':
        0xe20a, // file — arrange, arrow, cloud, copy, deliver
    'drive_file_move_outlined':
        0xeff8, // [outline] file — arrange, arrow, cloud, copy, deliver
    'drive_file_move_rounded':
        0xf6e5, // [round] file — arrange, arrow, cloud, copy, deliver
    'drive_file_move_rtl':
        0xf04f4, // file — arrange, arrow, arrows, cloud, copy
    'drive_file_move_rtl_outlined':
        0xf05ee, // [outline] file — arrange, arrow, arrows, cloud, copy
    'drive_file_move_rtl_rounded':
        0xf030d, // [round] file — arrange, arrow, arrows, cloud, copy
    'drive_file_move_rtl_sharp':
        0xf0400, // [sharp] file — arrange, arrow, arrows, cloud, copy
    'drive_file_move_sharp':
        0xe906, // [sharp] file — arrange, arrow, cloud, copy, deliver
    'drive_file_rename_outline':
        0xe20b, // file — archive, business, change, compose, create
    'drive_file_rename_outline_outlined':
        0xeff9, // [outline] file — archive, business, change, compose, create
    'drive_file_rename_outline_rounded':
        0xf6e6, // [round] file — archive, business, change, compose, create
    'drive_file_rename_outline_sharp':
        0xe907, // [sharp] file — archive, business, change, compose, create
    'drive_folder_upload': 0xe20c, // file — add, archive, arrow, backup, cloud
    'drive_folder_upload_outlined':
        0xeffa, // [outline] file — add, archive, arrow, backup, cloud
    'drive_folder_upload_rounded':
        0xf6e7, // [round] file — add, archive, arrow, backup, cloud
    'drive_folder_upload_sharp':
        0xe908, // [sharp] file — add, archive, arrow, backup, cloud
    'dry': 0xe20d, // places — air, air dry, appliance, bathroom, clothes
    'dry_cleaning': 0xe20e, // maps — apparel, bubble, care, chore, circle
    'dry_cleaning_outlined':
        0xeffb, // [outline] maps — apparel, bubble, care, chore, circle
    'dry_cleaning_rounded':
        0xf6e8, // [round] maps — apparel, bubble, care, chore, circle
    'dry_cleaning_sharp':
        0xe909, // [sharp] maps — apparel, bubble, care, chore, circle
    'dry_outlined':
        0xeffc, // [outline] places — air, air dry, appliance, bathroom, clothes
    'dry_rounded':
        0xf6e9, // [round] places — air, air dry, appliance, bathroom, clothes
    'dry_sharp':
        0xe90a, // [sharp] places — air, air dry, appliance, bathroom, clothes
    'duo': 0xe20f, // communication — account, avatar, call, chat, collaboration
    'duo_outlined':
        0xeffd, // [outline] communication — account, avatar, call, chat, collaboration
    'duo_rounded':
        0xf6ea, // [round] communication — account, avatar, call, chat, collaboration
    'duo_sharp':
        0xe90b, // [sharp] communication — account, avatar, call, chat, collaboration
    'dvr': 0xe210, // device — Android, OS, archives, audio, box
    'dvr_outlined':
        0xeffe, // [outline] device — Android, OS, archives, audio, box
    'dvr_rounded': 0xf6eb, // [round] device — Android, OS, archives, audio, box
    'dvr_sharp': 0xe90c, // [sharp] device — Android, OS, archives, audio, box
    'dynamic_feed':
        0xe211, // content — abstract, activity, articles, blocks, blog
    'dynamic_feed_outlined':
        0xefff, // [outline] content — abstract, activity, articles, blocks, blog
    'dynamic_feed_rounded':
        0xf6ec, // [round] content — abstract, activity, articles, blocks, blog
    'dynamic_feed_sharp':
        0xe90d, // [sharp] content — abstract, activity, articles, blocks, blog
    'dynamic_form': 0xe212, // action — adaptable, bolt, changing, choices, code
    'dynamic_form_outlined':
        0xf000, // [outline] action — adaptable, bolt, changing, choices, code
    'dynamic_form_rounded':
        0xf6ed, // [round] action — adaptable, bolt, changing, choices, code
    'dynamic_form_sharp':
        0xe90e, // [sharp] action — adaptable, bolt, changing, choices, code
    'e_mobiledata':
        0xe213, // device — alphabet, bars, cell, cell service, cellular
    'e_mobiledata_outlined':
        0xf001, // [outline] device — alphabet, bars, cell, cell service, cellular
    'e_mobiledata_rounded':
        0xf6ee, // [round] device — alphabet, bars, cell, cell service, cellular
    'e_mobiledata_sharp':
        0xe90f, // [sharp] device — alphabet, bars, cell, cell service, cellular
    'earbuds':
        0xe214, // hardware — accessory, audio, audio device, audio input, cable
    'earbuds_battery':
        0xe215, // hardware — accessory, audio, battery, battery charge, battery level
    'earbuds_battery_outlined':
        0xf002, // [outline] hardware — accessory, audio, battery, battery charge, battery level
    'earbuds_battery_rounded':
        0xf6ef, // [round] hardware — accessory, audio, battery, battery charge, battery level
    'earbuds_battery_sharp':
        0xe910, // [sharp] hardware — accessory, audio, battery, battery charge, battery level
    'earbuds_outlined':
        0xf003, // [outline] hardware — accessory, audio, audio device, audio input, cable
    'earbuds_rounded':
        0xf6f0, // [round] hardware — accessory, audio, audio device, audio input, cable
    'earbuds_sharp':
        0xe911, // [sharp] hardware — accessory, audio, audio device, audio input, cable
    'east':
        0xe216, // navigation — angle, arrow, compass, direction, directional
    'east_outlined':
        0xf004, // [outline] navigation — angle, arrow, compass, direction, directional
    'east_rounded':
        0xf6f1, // [round] navigation — angle, arrow, compass, direction, directional
    'east_sharp':
        0xe912, // [sharp] navigation — angle, arrow, compass, direction, directional
    'eco':
        0xe217, // Social — biodegradable, carbon footprint, conservation, earth, eco
    'eco_outlined':
        0xf005, // [outline] Social — biodegradable, carbon footprint, conservation, earth, eco
    'eco_rounded':
        0xf6f2, // [round] Social — biodegradable, carbon footprint, conservation, earth, eco
    'eco_sharp':
        0xe913, // [sharp] Social — biodegradable, carbon footprint, conservation, earth, eco
    'edgesensor_high': 0xe218, // device — Android, OS, bar, bars, cell
    'edgesensor_high_outlined':
        0xf006, // [outline] device — Android, OS, bar, bars, cell
    'edgesensor_high_rounded':
        0xf6f3, // [round] device — Android, OS, bar, bars, cell
    'edgesensor_high_sharp':
        0xe914, // [sharp] device — Android, OS, bar, bars, cell
    'edgesensor_low': 0xe219, // device — Android, OS, alert, antenna, bars
    'edgesensor_low_outlined':
        0xf007, // [outline] device — Android, OS, alert, antenna, bars
    'edgesensor_low_rounded':
        0xf6f4, // [round] device — Android, OS, alert, antenna, bars
    'edgesensor_low_sharp':
        0xe915, // [sharp] device — Android, OS, alert, antenna, bars
    'edit': 0xe21a, // image — alter, author, change, compose, create
    'edit_attributes':
        0xe21b, // maps — adjust, approve, attributes, attribution, change
    'edit_attributes_outlined':
        0xf008, // [outline] maps — adjust, approve, attributes, attribution, change
    'edit_attributes_rounded':
        0xf6f5, // [round] maps — adjust, approve, attributes, attribution, change
    'edit_attributes_sharp':
        0xe916, // [sharp] maps — adjust, approve, attributes, attribution, change
    'edit_calendar':
        0xf04f5, // action — agenda, annotate, appointment, booking, calendar
    'edit_calendar_outlined':
        0xf05ef, // [outline] action — agenda, annotate, appointment, booking, calendar
    'edit_calendar_rounded':
        0xf030e, // [round] action — agenda, annotate, appointment, booking, calendar
    'edit_calendar_sharp':
        0xf0401, // [sharp] action — agenda, annotate, appointment, booking, calendar
    'edit_document':
        0xf085d, // action — angle, annotation, change, compose, content
    'edit_location':
        0xe21c, // maps — address, alter, change, configure, correct
    'edit_location_alt': 0xe21d, // maps — address, adjust, alt, alter, change
    'edit_location_alt_outlined':
        0xf009, // [outline] maps — address, adjust, alt, alter, change
    'edit_location_alt_rounded':
        0xf6f6, // [round] maps — address, adjust, alt, alter, change
    'edit_location_alt_sharp':
        0xe917, // [sharp] maps — address, adjust, alt, alter, change
    'edit_location_outlined':
        0xf00a, // [outline] maps — address, alter, change, configure, correct
    'edit_location_rounded':
        0xf6f7, // [round] maps — address, alter, change, configure, correct
    'edit_location_sharp':
        0xe918, // [sharp] maps — address, alter, change, configure, correct
    'edit_note':
        0xf04f6, // editor — changes, compose, compose note, corrections, create
    'edit_note_outlined':
        0xf05f0, // [outline] editor — changes, compose, compose note, corrections, create
    'edit_note_rounded':
        0xf030f, // [round] editor — changes, compose, compose note, corrections, create
    'edit_note_sharp':
        0xf0402, // [sharp] editor — changes, compose, compose note, corrections, create
    'edit_notifications': 0xe21e, // social — active, adjust, alarm, alert, bell
    'edit_notifications_outlined':
        0xf00b, // [outline] social — active, adjust, alarm, alert, bell
    'edit_notifications_rounded':
        0xf6f8, // [round] social — active, adjust, alarm, alert, bell
    'edit_notifications_sharp':
        0xe919, // [sharp] social — active, adjust, alarm, alert, bell
    'edit_off':
        0xe21f, // action — blocked, can't edit, compose, create, diagonal line
    'edit_off_outlined':
        0xf00c, // [outline] action — blocked, can't edit, compose, create, diagonal line
    'edit_off_rounded':
        0xf6f9, // [round] action — blocked, can't edit, compose, create, diagonal line
    'edit_off_sharp':
        0xe91a, // [sharp] action — blocked, can't edit, compose, create, diagonal line
    'edit_outlined':
        0xf00d, // [outline] image — alter, author, change, compose, create
    'edit_road': 0xe220, // maps — adjust, annotate, change, curve, destination
    'edit_road_outlined':
        0xf00e, // [outline] maps — adjust, annotate, change, curve, destination
    'edit_road_rounded':
        0xf6fa, // [round] maps — adjust, annotate, change, curve, destination
    'edit_road_sharp':
        0xe91b, // [sharp] maps — adjust, annotate, change, curve, destination
    'edit_rounded':
        0xf6fb, // [round] image — alter, author, change, compose, create
    'edit_sharp':
        0xe91c, // [sharp] image — alter, author, change, compose, create
    'edit_square': 0xf085e, // action — alter, annotate, area, box, change
    'egg': 0xf04f8, // maps — animal, boiled, breakfast, broken, brunch
    'egg_alt': 0xf04f7, // maps — agriculture, bake, break, breakfast, brunch
    'egg_alt_outlined':
        0xf05f1, // [outline] maps — agriculture, bake, break, breakfast, brunch
    'egg_alt_rounded':
        0xf0310, // [round] maps — agriculture, bake, break, breakfast, brunch
    'egg_alt_sharp':
        0xf0403, // [sharp] maps — agriculture, bake, break, breakfast, brunch
    'egg_outlined':
        0xf05f2, // [outline] maps — animal, boiled, breakfast, broken, brunch
    'egg_rounded':
        0xf0311, // [round] maps — animal, boiled, breakfast, broken, brunch
    'egg_sharp':
        0xf0404, // [sharp] maps — animal, boiled, breakfast, broken, brunch
    'eight_k': 0xe031, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_outlined':
        0xee23, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_plus': 0xe032, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_plus_outlined':
        0xee24, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_plus_rounded':
        0xf510, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_plus_sharp':
        0xe731, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_rounded':
        0xf511, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_k_sharp':
        0xe732, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_mp': 0xe033, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_mp_outlined':
        0xee25, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_mp_rounded':
        0xf512, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eight_mp_sharp':
        0xe733, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eighteen_mp': 0xe009, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'eighteen_mp_outlined':
        0xedfb, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eighteen_mp_rounded':
        0xf4e8, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eighteen_mp_sharp':
        0xe709, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eighteen_up_rating': 0xf0784,
    'eighteen_up_rating_outlined': 0xf06d4,
    'eighteen_up_rating_rounded': 0xf07dc,
    'eighteen_up_rating_sharp': 0xf072c,
    'eject': 0xe221, // action — arrow, audio, bar, command, device
    'eject_outlined':
        0xf00f, // [outline] action — arrow, audio, bar, command, device
    'eject_rounded':
        0xf6fc, // [round] action — arrow, audio, bar, command, device
    'eject_sharp':
        0xe91d, // [sharp] action — arrow, audio, bar, command, device
    'elderly':
        0xe222, // social — account, account representation, age, avatar, body
    'elderly_outlined':
        0xf010, // [outline] social — account, account representation, age, avatar, body
    'elderly_rounded':
        0xf6fd, // [round] social — account, account representation, age, avatar, body
    'elderly_sharp':
        0xe91e, // [sharp] social — account, account representation, age, avatar, body
    'elderly_woman': 0xf04f9, // social — aged, avatar, body, cane, circle
    'elderly_woman_outlined':
        0xf05f3, // [outline] social — aged, avatar, body, cane, circle
    'elderly_woman_rounded':
        0xf0312, // [round] social — aged, avatar, body, cane, circle
    'elderly_woman_sharp':
        0xf0405, // [sharp] social — aged, avatar, body, cane, circle
    'electric_bike':
        0xe223, // maps — battery, battery bicycle, battery bike, bicycle, bike
    'electric_bike_outlined':
        0xf011, // [outline] maps — battery, battery bicycle, battery bike, bicycle, bike
    'electric_bike_rounded':
        0xf6fe, // [round] maps — battery, battery bicycle, battery bike, bicycle, bike
    'electric_bike_sharp':
        0xe91f, // [sharp] maps — battery, battery bicycle, battery bike, bicycle, bike
    'electric_bolt': 0xf079c, // home — alert, battery, bolt, charging, current
    'electric_bolt_outlined':
        0xf06ec, // [outline] home — alert, battery, bolt, charging, current
    'electric_bolt_rounded':
        0xf07f4, // [round] home — alert, battery, bolt, charging, current
    'electric_bolt_sharp':
        0xf0744, // [sharp] home — alert, battery, bolt, charging, current
    'electric_car': 0xe224, // maps — automobile, battery, bolt, car, cars
    'electric_car_outlined':
        0xf012, // [outline] maps — automobile, battery, bolt, car, cars
    'electric_car_rounded':
        0xf6ff, // [round] maps — automobile, battery, bolt, car, cars
    'electric_car_sharp':
        0xe920, // [sharp] maps — automobile, battery, bolt, car, cars
    'electric_meter': 0xf079d, // home — analog, bill, billing, bolt, building
    'electric_meter_outlined':
        0xf06ed, // [outline] home — analog, bill, billing, bolt, building
    'electric_meter_rounded':
        0xf07f5, // [round] home — analog, bill, billing, bolt, building
    'electric_meter_sharp':
        0xf0745, // [sharp] home — analog, bill, billing, bolt, building
    'electric_moped': 0xe225, // maps — automobile, battery, bike, bolt, car
    'electric_moped_outlined':
        0xf013, // [outline] maps — automobile, battery, bike, bolt, car
    'electric_moped_rounded':
        0xf700, // [round] maps — automobile, battery, bike, bolt, car
    'electric_moped_sharp':
        0xe921, // [sharp] maps — automobile, battery, bike, bolt, car
    'electric_rickshaw':
        0xe226, // maps — asia, auto rickshaw, automobile, bangkok, bolt
    'electric_rickshaw_outlined':
        0xf014, // [outline] maps — asia, auto rickshaw, automobile, bangkok, bolt
    'electric_rickshaw_rounded':
        0xf701, // [round] maps — asia, auto rickshaw, automobile, bangkok, bolt
    'electric_rickshaw_sharp':
        0xe922, // [sharp] maps — asia, auto rickshaw, automobile, bangkok, bolt
    'electric_scooter': 0xe227, // maps — battery, bike, bolt, city, commute
    'electric_scooter_outlined':
        0xf015, // [outline] maps — battery, bike, bolt, city, commute
    'electric_scooter_rounded':
        0xf702, // [round] maps — battery, bike, bolt, city, commute
    'electric_scooter_sharp':
        0xe923, // [sharp] maps — battery, bike, bolt, city, commute
    'electrical_services': 0xe228, // maps — bolt, bright, charge, circuit, cord
    'electrical_services_outlined':
        0xf016, // [outline] maps — bolt, bright, charge, circuit, cord
    'electrical_services_rounded':
        0xf703, // [round] maps — bolt, bright, charge, circuit, cord
    'electrical_services_sharp':
        0xe924, // [sharp] maps — bolt, bright, charge, circuit, cord
    'elevator': 0xe229, // places — abstract, access, architecture, arrows, body
    'elevator_outlined':
        0xf017, // [outline] places — abstract, access, architecture, arrows, body
    'elevator_rounded':
        0xf704, // [round] places — abstract, access, architecture, arrows, body
    'elevator_sharp':
        0xe925, // [sharp] places — abstract, access, architecture, arrows, body
    'eleven_mp': 0xe002, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'eleven_mp_outlined':
        0xedf4, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eleven_mp_rounded':
        0xf4e1, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'eleven_mp_sharp':
        0xe702, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'email':
        0xe22a, // communication — communication, contact, correspondence, diagonal lines, digital
    'email_outlined':
        0xf018, // [outline] communication — communication, contact, correspondence, diagonal lines, digital
    'email_rounded':
        0xf705, // [round] communication — communication, contact, correspondence, diagonal lines, digital
    'email_sharp':
        0xe926, // [sharp] communication — communication, contact, correspondence, diagonal lines, digital
    'emergency':
        0xf04fa, // maps — alarm, alert, assistance, asterisk, attention
    'emergency_outlined':
        0xf05f4, // [outline] maps — alarm, alert, assistance, asterisk, attention
    'emergency_recording':
        0xf079e, // maps — alert, attention, camera, capture, caution
    'emergency_recording_outlined':
        0xf06ee, // [outline] maps — alert, attention, camera, capture, caution
    'emergency_recording_rounded':
        0xf07f6, // [round] maps — alert, attention, camera, capture, caution
    'emergency_recording_sharp':
        0xf0746, // [sharp] maps — alert, attention, camera, capture, caution
    'emergency_rounded':
        0xf0313, // [round] maps — alarm, alert, assistance, asterisk, attention
    'emergency_share':
        0xf079f, // maps — alert, assist, attention, broadcast, call for help
    'emergency_share_outlined':
        0xf06ef, // [outline] maps — alert, assist, attention, broadcast, call for help
    'emergency_share_rounded':
        0xf07f7, // [round] maps — alert, assist, attention, broadcast, call for help
    'emergency_share_sharp':
        0xf0747, // [sharp] maps — alert, assist, attention, broadcast, call for help
    'emergency_sharp':
        0xf0406, // [sharp] maps — alarm, alert, assistance, asterisk, attention
    'emoji_emotions': 0xe22b, // social — +, add, character, chat, cheerful
    'emoji_emotions_outlined':
        0xf019, // [outline] social — +, add, character, chat, cheerful
    'emoji_emotions_rounded':
        0xf706, // [round] social — +, add, character, chat, cheerful
    'emoji_emotions_sharp':
        0xe927, // [sharp] social — +, add, character, chat, cheerful
    'emoji_events':
        0xe22c, // social — accomplishment, achievement, achievement award, award, celebration
    'emoji_events_outlined':
        0xf01a, // [outline] social — accomplishment, achievement, achievement award, award, celebration
    'emoji_events_rounded':
        0xf707, // [round] social — accomplishment, achievement, achievement award, award, celebration
    'emoji_events_sharp':
        0xe928, // [sharp] social — accomplishment, achievement, achievement award, award, celebration
    'emoji_flags': 0xe22d,
    'emoji_flags_outlined': 0xf01b,
    'emoji_flags_rounded': 0xf708,
    'emoji_flags_sharp': 0xe929,
    'emoji_food_beverage':
        0xe22e, // social — beverage, break, cafe, caffeine, ceramic
    'emoji_food_beverage_outlined':
        0xf01c, // [outline] social — beverage, break, cafe, caffeine, ceramic
    'emoji_food_beverage_rounded':
        0xf709, // [round] social — beverage, break, cafe, caffeine, ceramic
    'emoji_food_beverage_sharp':
        0xe92a, // [sharp] social — beverage, break, cafe, caffeine, ceramic
    'emoji_nature': 0xe22f, // social — animal, bee, botany, branch, bug
    'emoji_nature_outlined':
        0xf01d, // [outline] social — animal, bee, botany, branch, bug
    'emoji_nature_rounded':
        0xf70a, // [round] social — animal, bee, botany, branch, bug
    'emoji_nature_sharp':
        0xe92b, // [sharp] social — animal, bee, botany, branch, bug
    'emoji_objects': 0xe230, // social — avatar, bulb, cartoon, character, chat
    'emoji_objects_outlined':
        0xf01e, // [outline] social — avatar, bulb, cartoon, character, chat
    'emoji_objects_rounded':
        0xf70b, // [round] social — avatar, bulb, cartoon, character, chat
    'emoji_objects_sharp':
        0xe92c, // [sharp] social — avatar, bulb, cartoon, character, chat
    'emoji_people':
        0xe231, // social — accounts, arm, assembly, audience, avatars
    'emoji_people_outlined':
        0xf01f, // [outline] social — accounts, arm, assembly, audience, avatars
    'emoji_people_rounded':
        0xf70c, // [round] social — accounts, arm, assembly, audience, avatars
    'emoji_people_sharp':
        0xe92d, // [sharp] social — accounts, arm, assembly, audience, avatars
    'emoji_symbols':
        0xe232, // social — add emoji, ampersand, character, chat, communication
    'emoji_symbols_outlined':
        0xf020, // [outline] social — add emoji, ampersand, character, chat, communication
    'emoji_symbols_rounded':
        0xf70d, // [round] social — add emoji, ampersand, character, chat, communication
    'emoji_symbols_sharp':
        0xe92e, // [sharp] social — add emoji, ampersand, character, chat, communication
    'emoji_transportation':
        0xe233, // social — architecture, arrow, automobile, building, car
    'emoji_transportation_outlined':
        0xf021, // [outline] social — architecture, arrow, automobile, building, car
    'emoji_transportation_rounded':
        0xf70e, // [round] social — architecture, arrow, automobile, building, car
    'emoji_transportation_sharp':
        0xe92f, // [sharp] social — architecture, arrow, automobile, building, car
    'energy_savings_leaf':
        0xf07a0, // home — battery saver, configuration, conservation, eco, eco-friendly
    'energy_savings_leaf_outlined':
        0xf06f0, // [outline] home — battery saver, configuration, conservation, eco, eco-friendly
    'energy_savings_leaf_rounded':
        0xf07f8, // [round] home — battery saver, configuration, conservation, eco, eco-friendly
    'energy_savings_leaf_sharp':
        0xf0748, // [sharp] home — battery saver, configuration, conservation, eco, eco-friendly
    'engineering':
        0xe234, // social — adjustment, automation, body, building, cog
    'engineering_outlined':
        0xf022, // [outline] social — adjustment, automation, body, building, cog
    'engineering_rounded':
        0xf70f, // [round] social — adjustment, automation, body, building, cog
    'engineering_sharp':
        0xe930, // [sharp] social — adjustment, automation, body, building, cog
    'enhance_photo_translate': 0xe131,
    'enhance_photo_translate_outlined': 0xef1f,
    'enhance_photo_translate_rounded': 0xf60c,
    'enhance_photo_translate_sharp': 0xe82d,
    'enhanced_encryption':
        0xe235, // notification — +, access, add, authorized, breaking encryption
    'enhanced_encryption_outlined':
        0xf023, // [outline] notification — +, access, add, authorized, breaking encryption
    'enhanced_encryption_rounded':
        0xf710, // [round] notification — +, access, add, authorized, breaking encryption
    'enhanced_encryption_sharp':
        0xe931, // [sharp] notification — +, access, add, authorized, breaking encryption
    'equalizer':
        0xe236, // av — adjust, adjustment, analytics, audio, audio control
    'equalizer_outlined':
        0xf024, // [outline] av — adjust, adjustment, analytics, audio, audio control
    'equalizer_rounded':
        0xf711, // [round] av — adjust, adjustment, analytics, audio, audio control
    'equalizer_sharp':
        0xe932, // [sharp] av — adjust, adjustment, analytics, audio, audio control
    'error': 0xe237, // alert — !, alert, attention, bug, caution
    'error_outline': 0xe238, // alert — !, alert, attention, bug, caution
    'error_outline_outlined':
        0xf025, // [outline] alert — !, alert, attention, bug, caution
    'error_outline_rounded':
        0xf712, // [round] alert — !, alert, attention, bug, caution
    'error_outline_sharp':
        0xe933, // [sharp] alert — !, alert, attention, bug, caution
    'error_outlined':
        0xf026, // [outline] alert — !, alert, attention, bug, caution
    'error_rounded':
        0xf713, // [round] alert — !, alert, attention, bug, caution
    'error_sharp': 0xe934, // [sharp] alert — !, alert, attention, bug, caution
    'escalator':
        0xe239, // places — access, accessibility, airport, arrow, ascend
    'escalator_outlined':
        0xf027, // [outline] places — access, accessibility, airport, arrow, ascend
    'escalator_rounded':
        0xf714, // [round] places — access, accessibility, airport, arrow, ascend
    'escalator_sharp':
        0xe935, // [sharp] places — access, accessibility, airport, arrow, ascend
    'escalator_warning':
        0xe23a, // places — alert, attention, body, broken, building
    'escalator_warning_outlined':
        0xf028, // [outline] places — alert, attention, body, broken, building
    'escalator_warning_rounded':
        0xf715, // [round] places — alert, attention, body, broken, building
    'escalator_warning_sharp':
        0xe936, // [sharp] places — alert, attention, body, broken, building
    'euro': 0xe23b, // image — banking, bill, card, cash, coin
    'euro_outlined':
        0xf029, // [outline] image — banking, bill, card, cash, coin
    'euro_rounded': 0xf716, // [round] image — banking, bill, card, cash, coin
    'euro_sharp': 0xe937, // [sharp] image — banking, bill, card, cash, coin
    'euro_symbol': 0xe23c, // action — banking, bill, business, buy, card
    'euro_symbol_outlined':
        0xf02a, // [outline] action — banking, bill, business, buy, card
    'euro_symbol_rounded':
        0xf717, // [round] action — banking, bill, business, buy, card
    'euro_symbol_sharp':
        0xe938, // [sharp] action — banking, bill, business, buy, card
    'ev_station': 0xe23d, // maps — automobile, battery, bolt, car, cars
    'ev_station_outlined':
        0xf02b, // [outline] maps — automobile, battery, bolt, car, cars
    'ev_station_rounded':
        0xf718, // [round] maps — automobile, battery, bolt, car, cars
    'ev_station_sharp':
        0xe939, // [sharp] maps — automobile, battery, bolt, car, cars
    'event':
        0xe23e, // action — add, add event, add invitation, add to calendar, agenda
    'event_available':
        0xe23f, // notification — agenda, appointment, approve, availability, available
    'event_available_outlined':
        0xf02c, // [outline] notification — agenda, appointment, approve, availability, available
    'event_available_rounded':
        0xf719, // [round] notification — agenda, appointment, approve, availability, available
    'event_available_sharp':
        0xe93a, // [sharp] notification — agenda, appointment, approve, availability, available
    'event_busy':
        0xe240, // notification — appointment, blocked, booked, busy, calendar
    'event_busy_outlined':
        0xf02d, // [outline] notification — appointment, blocked, booked, busy, calendar
    'event_busy_rounded':
        0xf71a, // [round] notification — appointment, blocked, booked, busy, calendar
    'event_busy_sharp':
        0xe93b, // [sharp] notification — appointment, blocked, booked, busy, calendar
    'event_note':
        0xe241, // notification — activity, agenda, appointment, booking, calendar
    'event_note_outlined':
        0xf02e, // [outline] notification — activity, agenda, appointment, booking, calendar
    'event_note_rounded':
        0xf71b, // [round] notification — activity, agenda, appointment, booking, calendar
    'event_note_sharp':
        0xe93c, // [sharp] notification — activity, agenda, appointment, booking, calendar
    'event_outlined':
        0xf02f, // [outline] action — add, add event, add invitation, add to calendar, agenda
    'event_repeat':
        0xf04fb, // action — agenda, always, appointment, around, calendar
    'event_repeat_outlined':
        0xf05f5, // [outline] action — agenda, always, appointment, around, calendar
    'event_repeat_rounded':
        0xf0314, // [round] action — agenda, always, appointment, around, calendar
    'event_repeat_sharp':
        0xf0407, // [sharp] action — agenda, always, appointment, around, calendar
    'event_rounded':
        0xf71c, // [round] action — add, add event, add invitation, add to calendar, agenda
    'event_seat':
        0xe242, // action — allocation, arrangement, assign, assigned, available
    'event_seat_outlined':
        0xf030, // [outline] action — allocation, arrangement, assign, assigned, available
    'event_seat_rounded':
        0xf71d, // [round] action — allocation, arrangement, assign, assigned, available
    'event_seat_sharp':
        0xe93d, // [sharp] action — allocation, arrangement, assign, assigned, available
    'event_sharp':
        0xe93e, // [sharp] action — add, add event, add invitation, add to calendar, agenda
    'exit_to_app': 0xe243, // action — abandon, access, account, arrow, block
    'exit_to_app_outlined':
        0xf031, // [outline] action — abandon, access, account, arrow, block
    'exit_to_app_rounded':
        0xf71e, // [round] action — abandon, access, account, arrow, block
    'exit_to_app_sharp':
        0xe93f, // [sharp] action — abandon, access, account, arrow, block
    'expand': 0xe244, // action — arrow, arrows, aspect ratio, bigger, compress
    'expand_circle_down':
        0xf04fc, // navigation — arrow, arrows, chevron, circle, circle button
    'expand_circle_down_outlined':
        0xf05f6, // [outline] navigation — arrow, arrows, chevron, circle, circle button
    'expand_circle_down_rounded':
        0xf0315, // [round] navigation — arrow, arrows, chevron, circle, circle button
    'expand_circle_down_sharp':
        0xf0408, // [sharp] navigation — arrow, arrows, chevron, circle, circle button
    'expand_less':
        0xe245, // navigation — accordion, angle up, arrow, arrow up, arrows
    'expand_less_outlined':
        0xf032, // [outline] navigation — accordion, angle up, arrow, arrow up, arrows
    'expand_less_rounded':
        0xf71f, // [round] navigation — accordion, angle up, arrow, arrow up, arrows
    'expand_less_sharp':
        0xe940, // [sharp] navigation — accordion, angle up, arrow, arrow up, arrows
    'expand_more':
        0xe246, // navigation — accordion, arrow, arrows, caret, caret-down
    'expand_more_outlined':
        0xf033, // [outline] navigation — accordion, arrow, arrows, caret, caret-down
    'expand_more_rounded':
        0xf720, // [round] navigation — accordion, arrow, arrows, caret, caret-down
    'expand_more_sharp':
        0xe941, // [sharp] navigation — accordion, arrow, arrows, caret, caret-down
    'expand_outlined':
        0xf034, // [outline] action — arrow, arrows, aspect ratio, bigger, compress
    'expand_rounded':
        0xf721, // [round] action — arrow, arrows, aspect ratio, bigger, compress
    'expand_sharp':
        0xe942, // [sharp] action — arrow, arrows, aspect ratio, bigger, compress
    'explicit': 0xe247, // av — access, adult, advisory, alphabet, block
    'explicit_outlined':
        0xf035, // [outline] av — access, adult, advisory, alphabet, block
    'explicit_rounded':
        0xf722, // [round] av — access, adult, advisory, alphabet, block
    'explicit_sharp':
        0xe943, // [sharp] av — access, adult, advisory, alphabet, block
    'explore':
        0xe248, // action — adventure, browse, compass, curiosity, destination
    'explore_off':
        0xe249, // action — adventure off, compass, compass blocked, compass off, destination
    'explore_off_outlined':
        0xf036, // [outline] action — adventure off, compass, compass blocked, compass off, destination
    'explore_off_rounded':
        0xf723, // [round] action — adventure off, compass, compass blocked, compass off, destination
    'explore_off_sharp':
        0xe944, // [sharp] action — adventure off, compass, compass blocked, compass off, destination
    'explore_outlined':
        0xf037, // [outline] action — adventure, browse, compass, curiosity, destination
    'explore_rounded':
        0xf724, // [round] action — adventure, browse, compass, curiosity, destination
    'explore_sharp':
        0xe945, // [sharp] action — adventure, browse, compass, curiosity, destination
    'exposure': 0xe24a, // image — add, adjustment, bar, brightness, camera
    'exposure_minus_1': 0xe24b,
    'exposure_minus_1_outlined': 0xf038,
    'exposure_minus_1_rounded': 0xf725,
    'exposure_minus_1_sharp': 0xe946,
    'exposure_minus_2': 0xe24c,
    'exposure_minus_2_outlined': 0xf039,
    'exposure_minus_2_rounded': 0xf726,
    'exposure_minus_2_sharp': 0xe947,
    'exposure_neg_1':
        0xe24b, // image — 1, adjust, brightness, brightness adjustment, camera control
    'exposure_neg_1_outlined':
        0xf038, // [outline] image — 1, adjust, brightness, brightness adjustment, camera control
    'exposure_neg_1_rounded':
        0xf725, // [round] image — 1, adjust, brightness, brightness adjustment, camera control
    'exposure_neg_1_sharp':
        0xe946, // [sharp] image — 1, adjust, brightness, brightness adjustment, camera control
    'exposure_neg_2': 0xe24c, // image — 2, adjust, brightness, camera, contrast
    'exposure_neg_2_outlined':
        0xf039, // [outline] image — 2, adjust, brightness, camera, contrast
    'exposure_neg_2_rounded':
        0xf726, // [round] image — 2, adjust, brightness, camera, contrast
    'exposure_neg_2_sharp':
        0xe947, // [sharp] image — 2, adjust, brightness, camera, contrast
    'exposure_outlined':
        0xf03a, // [outline] image — add, adjustment, bar, brightness, camera
    'exposure_plus_1':
        0xe24d, // image — 1, add, adjustment, arithmetic, brightness
    'exposure_plus_1_outlined':
        0xf03b, // [outline] image — 1, add, adjustment, arithmetic, brightness
    'exposure_plus_1_rounded':
        0xf727, // [round] image — 1, add, adjustment, arithmetic, brightness
    'exposure_plus_1_sharp':
        0xe948, // [sharp] image — 1, add, adjustment, arithmetic, brightness
    'exposure_plus_2': 0xe24e, // image — 2, add, adjust, adjustment, brightness
    'exposure_plus_2_outlined':
        0xf03c, // [outline] image — 2, add, adjust, adjustment, brightness
    'exposure_plus_2_rounded':
        0xf728, // [round] image — 2, add, adjust, adjustment, brightness
    'exposure_plus_2_sharp':
        0xe949, // [sharp] image — 2, add, adjust, adjustment, brightness
    'exposure_rounded':
        0xf729, // [round] image — add, adjustment, bar, brightness, camera
    'exposure_sharp':
        0xe94a, // [sharp] image — add, adjustment, bar, brightness, camera
    'exposure_zero': 0xe24f, // image — 0, adjust, balance, brightness, camera
    'exposure_zero_outlined':
        0xf03d, // [outline] image — 0, adjust, balance, brightness, camera
    'exposure_zero_rounded':
        0xf72a, // [round] image — 0, adjust, balance, brightness, camera
    'exposure_zero_sharp':
        0xe94b, // [sharp] image — 0, adjust, balance, brightness, camera
    'extension':
        0xe250, // action — addon, browser-extension, compatibility, connect, connection
    'extension_off':
        0xe251, // action — addon, block, browser, cancel, deactivate
    'extension_off_outlined':
        0xf03e, // [outline] action — addon, block, browser, cancel, deactivate
    'extension_off_rounded':
        0xf72b, // [round] action — addon, block, browser, cancel, deactivate
    'extension_off_sharp':
        0xe94c, // [sharp] action — addon, block, browser, cancel, deactivate
    'extension_outlined':
        0xf03f, // [outline] action — addon, browser-extension, compatibility, connect, connection
    'extension_rounded':
        0xf72c, // [round] action — addon, browser-extension, compatibility, connect, connection
    'extension_sharp':
        0xe94d, // [sharp] action — addon, browser-extension, compatibility, connect, connection
    'face':
        0xe252, // action — access, account, authentication, authorized, biometric
    'face_2': 0xf085f, // social — account, amiable, avatar, character, cheerful
    'face_2_outlined':
        0xf08a2, // [outline] social — account, amiable, avatar, character, cheerful
    'face_2_rounded':
        0xf0884, // [round] social — account, amiable, avatar, character, cheerful
    'face_2_sharp':
        0xf083b, // [sharp] social — account, amiable, avatar, character, cheerful
    'face_3': 0xf0860, // social — account, avatar, avatar 3, emoji, eyes
    'face_3_outlined':
        0xf08a3, // [outline] social — account, avatar, avatar 3, emoji, eyes
    'face_3_rounded':
        0xf0885, // [round] social — account, avatar, avatar 3, emoji, eyes
    'face_3_sharp':
        0xf083c, // [sharp] social — account, avatar, avatar 3, emoji, eyes
    'face_4': 0xf0861, // social — account, avatar, bland, character, circle
    'face_4_outlined':
        0xf08a4, // [outline] social — account, avatar, bland, character, circle
    'face_4_rounded':
        0xf0886, // [round] social — account, avatar, bland, character, circle
    'face_4_sharp':
        0xf083d, // [sharp] social — account, avatar, bland, character, circle
    'face_5':
        0xf0862, // social — account, avatar, character, communication, emoji
    'face_5_outlined':
        0xf08a5, // [outline] social — account, avatar, character, communication, emoji
    'face_5_rounded':
        0xf0887, // [round] social — account, avatar, character, communication, emoji
    'face_5_sharp':
        0xf083e, // [sharp] social — account, avatar, character, communication, emoji
    'face_6':
        0xf0863, // social — account, avatar, cheerful, contented, delighted
    'face_6_outlined':
        0xf08a6, // [outline] social — account, avatar, cheerful, contented, delighted
    'face_6_rounded':
        0xf0888, // [round] social — account, avatar, cheerful, contented, delighted
    'face_6_sharp':
        0xf083f, // [sharp] social — account, avatar, cheerful, contented, delighted
    'face_outlined':
        0xf040, // [outline] action — access, account, authentication, authorized, biometric
    'face_retouching_natural':
        0xe253, // image — adjust, ai, artificial, automatic, automation
    'face_retouching_natural_outlined':
        0xf041, // [outline] image — adjust, ai, artificial, automatic, automation
    'face_retouching_natural_rounded':
        0xf72d, // [round] image — adjust, ai, artificial, automatic, automation
    'face_retouching_natural_sharp':
        0xe94e, // [sharp] image — adjust, ai, artificial, automatic, automation
    'face_retouching_off':
        0xe254, // image — avatar, beauty, blemish, block, cancel
    'face_retouching_off_outlined':
        0xf042, // [outline] image — avatar, beauty, blemish, block, cancel
    'face_retouching_off_rounded':
        0xf72e, // [round] image — avatar, beauty, blemish, block, cancel
    'face_retouching_off_sharp':
        0xe94f, // [sharp] image — avatar, beauty, blemish, block, cancel
    'face_rounded':
        0xf72f, // [round] action — access, account, authentication, authorized, biometric
    'face_sharp':
        0xe950, // [sharp] action — access, account, authentication, authorized, biometric
    'face_unlock_outlined':
        0xf043, // [outline] action — access, account, authentication, authorized, biometric
    'face_unlock_rounded':
        0xf730, // [round] action — access, account, authentication, authorized, biometric
    'face_unlock_sharp':
        0xe951, // [sharp] action — access, account, authentication, authorized, biometric
    'facebook': 0xe255, // brand logo
    'facebook_outlined': 0xf044, // [outline] brand logo
    'facebook_rounded': 0xf731, // [round] brand logo
    'facebook_sharp': 0xe952, // [sharp] brand logo
    'fact_check':
        0xe256, // action — accuracy, accurate, approval, approve, audit
    'fact_check_outlined':
        0xf045, // [outline] action — accuracy, accurate, approval, approve, audit
    'fact_check_rounded':
        0xf732, // [round] action — accuracy, accurate, approval, approve, audit
    'fact_check_sharp':
        0xe953, // [sharp] action — accuracy, accurate, approval, approve, audit
    'factory':
        0xf04fd, // maps — architecture, assembly, automation, building, business
    'factory_outlined':
        0xf05f7, // [outline] maps — architecture, assembly, automation, building, business
    'factory_rounded':
        0xf0316, // [round] maps — architecture, assembly, automation, building, business
    'factory_sharp':
        0xf0409, // [sharp] maps — architecture, assembly, automation, building, business
    'family_restroom':
        0xe257, // places — accessibility, amenities, baby, bathroom, changing station
    'family_restroom_outlined':
        0xf046, // [outline] places — accessibility, amenities, baby, bathroom, changing station
    'family_restroom_rounded':
        0xf733, // [round] places — accessibility, amenities, baby, bathroom, changing station
    'family_restroom_sharp':
        0xe954, // [sharp] places — accessibility, amenities, baby, bathroom, changing station
    'fast_forward':
        0xe258, // av — accelerate, advance, arrow, audio, audio visual
    'fast_forward_outlined':
        0xf047, // [outline] av — accelerate, advance, arrow, audio, audio visual
    'fast_forward_rounded':
        0xf734, // [round] av — accelerate, advance, arrow, audio, audio visual
    'fast_forward_sharp':
        0xe955, // [sharp] av — accelerate, advance, arrow, audio, audio visual
    'fast_rewind':
        0xe259, // av — accelerate, audio, back, backward, double arrows
    'fast_rewind_outlined':
        0xf048, // [outline] av — accelerate, audio, back, backward, double arrows
    'fast_rewind_rounded':
        0xf735, // [round] av — accelerate, audio, back, backward, double arrows
    'fast_rewind_sharp':
        0xe956, // [sharp] av — accelerate, audio, back, backward, double arrows
    'fastfood':
        0xe25a, // maps — american food, bun, burger, cheeseburger, circle
    'fastfood_outlined':
        0xf049, // [outline] maps — american food, bun, burger, cheeseburger, circle
    'fastfood_rounded':
        0xf736, // [round] maps — american food, bun, burger, cheeseburger, circle
    'fastfood_sharp':
        0xe957, // [sharp] maps — american food, bun, burger, cheeseburger, circle
    'favorite':
        0xe25b, // action — affection, appreciate, appreciation, bookmark, empty
    'favorite_border':
        0xe25c, // action — affection, appreciation, bookmark, empty, engagement
    'favorite_border_outlined':
        0xf04a, // [outline] action — affection, appreciation, bookmark, empty, engagement
    'favorite_border_rounded':
        0xf737, // [round] action — affection, appreciation, bookmark, empty, engagement
    'favorite_border_sharp':
        0xe958, // [sharp] action — affection, appreciation, bookmark, empty, engagement
    'favorite_outline':
        0xe25c, // action — affection, appreciation, bookmark, empty, engagement
    'favorite_outline_outlined':
        0xf04a, // [outline] action — affection, appreciation, bookmark, empty, engagement
    'favorite_outline_rounded':
        0xf737, // [round] action — affection, appreciation, bookmark, empty, engagement
    'favorite_outline_sharp':
        0xe958, // [sharp] action — affection, appreciation, bookmark, empty, engagement
    'favorite_outlined':
        0xf04b, // [outline] action — affection, appreciate, appreciation, bookmark, empty
    'favorite_rounded':
        0xf738, // [round] action — affection, appreciate, appreciation, bookmark, empty
    'favorite_sharp':
        0xe959, // [sharp] action — affection, appreciate, appreciation, bookmark, empty
    'fax':
        0xf04fe, // action — apparatus, appliance, business, communication, device
    'fax_outlined':
        0xf05f8, // [outline] action — apparatus, appliance, business, communication, device
    'fax_rounded':
        0xf0317, // [round] action — apparatus, appliance, business, communication, device
    'fax_sharp':
        0xf040a, // [sharp] action — apparatus, appliance, business, communication, device
    'featured_play_list':
        0xe25d, // av — album, arrangement, audio, bullet points, content
    'featured_play_list_outlined':
        0xf04c, // [outline] av — album, arrangement, audio, bullet points, content
    'featured_play_list_rounded':
        0xf739, // [round] av — album, arrangement, audio, bullet points, content
    'featured_play_list_sharp':
        0xe95a, // [sharp] av — album, arrangement, audio, bullet points, content
    'featured_video':
        0xe25e, // av — advertised, advertisement, cinema, circle, clip
    'featured_video_outlined':
        0xf04d, // [outline] av — advertised, advertisement, cinema, circle, clip
    'featured_video_rounded':
        0xf73a, // [round] av — advertised, advertisement, cinema, circle, clip
    'featured_video_sharp':
        0xe95b, // [sharp] av — advertised, advertisement, cinema, circle, clip
    'feed': 0xe25f, // search — abstract, article, atom, blog, broadcasting
    'feed_outlined':
        0xf04e, // [outline] search — abstract, article, atom, blog, broadcasting
    'feed_rounded':
        0xf73b, // [round] search — abstract, article, atom, blog, broadcasting
    'feed_sharp':
        0xe95c, // [sharp] search — abstract, article, atom, blog, broadcasting
    'feedback': 0xe260, // action — !, alert, announcement, attention, broadcast
    'feedback_outlined':
        0xf04f, // [outline] action — !, alert, announcement, attention, broadcast
    'feedback_rounded':
        0xf73c, // [round] action — !, alert, announcement, attention, broadcast
    'feedback_sharp':
        0xe95d, // [sharp] action — !, alert, announcement, attention, broadcast
    'female':
        0xe261, // social — account, addition, avatar, biological, biological sex
    'female_outlined':
        0xf050, // [outline] social — account, addition, avatar, biological, biological sex
    'female_rounded':
        0xf73d, // [round] social — account, addition, avatar, biological, biological sex
    'female_sharp':
        0xe95e, // [sharp] social — account, addition, avatar, biological, biological sex
    'fence':
        0xe262, // places — backyard, barrier, boundaries, boundary, boundary line
    'fence_outlined':
        0xf051, // [outline] places — backyard, barrier, boundaries, boundary, boundary line
    'fence_rounded':
        0xf73e, // [round] places — backyard, barrier, boundaries, boundary, boundary line
    'fence_sharp':
        0xe95f, // [sharp] places — backyard, barrier, boundaries, boundary, boundary line
    'festival': 0xe263, // maps — art, calendar, celebration, circus, community
    'festival_outlined':
        0xf052, // [outline] maps — art, calendar, celebration, circus, community
    'festival_rounded':
        0xf73f, // [round] maps — art, calendar, celebration, circus, community
    'festival_sharp':
        0xe960, // [sharp] maps — art, calendar, celebration, circus, community
    'fiber_dvr':
        0xe264, // av — alphabet, box, broadcast, character, communication
    'fiber_dvr_outlined':
        0xf053, // [outline] av — alphabet, box, broadcast, character, communication
    'fiber_dvr_rounded':
        0xf740, // [round] av — alphabet, box, broadcast, character, communication
    'fiber_dvr_sharp':
        0xe961, // [sharp] av — alphabet, box, broadcast, character, communication
    'fiber_manual_record':
        0xe265, // av — active, alert, audio, broadcast, circle
    'fiber_manual_record_outlined':
        0xf054, // [outline] av — active, alert, audio, broadcast, circle
    'fiber_manual_record_rounded':
        0xf741, // [round] av — active, alert, audio, broadcast, circle
    'fiber_manual_record_sharp':
        0xe962, // [sharp] av — active, alert, audio, broadcast, circle
    'fiber_new': 0xe266, // av — alphabet, broadband, cable, character, circle
    'fiber_new_outlined':
        0xf055, // [outline] av — alphabet, broadband, cable, character, circle
    'fiber_new_rounded':
        0xf742, // [round] av — alphabet, broadband, cable, character, circle
    'fiber_new_sharp':
        0xe963, // [sharp] av — alphabet, broadband, cable, character, circle
    'fiber_pin':
        0xe267, // av — alphabet, broadband, cable, character, communication
    'fiber_pin_outlined':
        0xf056, // [outline] av — alphabet, broadband, cable, character, communication
    'fiber_pin_rounded':
        0xf743, // [round] av — alphabet, broadband, cable, character, communication
    'fiber_pin_sharp':
        0xe964, // [sharp] av — alphabet, broadband, cable, character, communication
    'fiber_smart_record':
        0xe268, // av — audio, audio recording, automatic, automation, capture
    'fiber_smart_record_outlined':
        0xf057, // [outline] av — audio, audio recording, automatic, automation, capture
    'fiber_smart_record_rounded':
        0xf744, // [round] av — audio, audio recording, automatic, automation, capture
    'fiber_smart_record_sharp':
        0xe965, // [sharp] av — audio, audio recording, automatic, automation, capture
    'fifteen_mp': 0xe006, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'fifteen_mp_outlined':
        0xedf8, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'fifteen_mp_rounded':
        0xf4e5, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'fifteen_mp_sharp':
        0xe706, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'file_copy': 0xe269, // content — archive, backup, clone, content, copy
    'file_copy_outlined':
        0xf058, // [outline] content — archive, backup, clone, content, copy
    'file_copy_rounded':
        0xf745, // [round] content — archive, backup, clone, content, copy
    'file_copy_sharp':
        0xe966, // [sharp] content — archive, backup, clone, content, copy
    'file_download': 0xe26a, // file — acquire, archive, arrow, arrows, bar
    'file_download_done':
        0xe26b, // file — arrow, arrow and check, arrows, check, checkmark
    'file_download_done_outlined':
        0xf059, // [outline] file — arrow, arrow and check, arrows, check, checkmark
    'file_download_done_rounded':
        0xf746, // [round] file — arrow, arrow and check, arrows, check, checkmark
    'file_download_done_sharp':
        0xe967, // [sharp] file — arrow, arrow and check, arrows, check, checkmark
    'file_download_off':
        0xe26c, // file — arrow, blocked, cancelled, cannot download, disabled
    'file_download_off_outlined':
        0xf05a, // [outline] file — arrow, blocked, cancelled, cannot download, disabled
    'file_download_off_rounded':
        0xf747, // [round] file — arrow, blocked, cancelled, cannot download, disabled
    'file_download_off_sharp':
        0xe968, // [sharp] file — arrow, blocked, cancelled, cannot download, disabled
    'file_download_outlined':
        0xf05b, // [outline] file — acquire, archive, arrow, arrows, bar
    'file_download_rounded':
        0xf748, // [round] file — acquire, archive, arrow, arrows, bar
    'file_download_sharp':
        0xe969, // [sharp] file — acquire, archive, arrow, arrows, bar
    'file_open':
        0xf04ff, // file — access, access file, administration, arrow, browse
    'file_open_outlined':
        0xf05f9, // [outline] file — access, access file, administration, arrow, browse
    'file_open_rounded':
        0xf0318, // [round] file — access, access file, administration, arrow, browse
    'file_open_sharp':
        0xf040b, // [sharp] file — access, access file, administration, arrow, browse
    'file_present':
        0xe26d, // action — business, clip, collaboration, communication, conference
    'file_present_outlined':
        0xf05c, // [outline] action — business, clip, collaboration, communication, conference
    'file_present_rounded':
        0xf749, // [round] action — business, clip, collaboration, communication, conference
    'file_present_sharp':
        0xe96a, // [sharp] action — business, clip, collaboration, communication, conference
    'file_upload': 0xe26e, // file — add, arrow, arrows, attach, backup
    'file_upload_off': 0xf0864, // file — arrow, arrows, barred, blocked, cancel
    'file_upload_outlined':
        0xf05d, // [outline] file — add, arrow, arrows, attach, backup
    'file_upload_rounded':
        0xf74a, // [round] file — add, arrow, arrows, attach, backup
    'file_upload_sharp':
        0xe96b, // [sharp] file — add, arrow, arrows, attach, backup
    'filter':
        0xe26f, // image — adjustments, categorization, categorize, choices, collections
    'filter_1': 0xe270, // image — 1, adjust, amount, choice, count
    'filter_1_outlined':
        0xf05e, // [outline] image — 1, adjust, amount, choice, count
    'filter_1_rounded':
        0xf74b, // [round] image — 1, adjust, amount, choice, count
    'filter_1_sharp':
        0xe96c, // [sharp] image — 1, adjust, amount, choice, count
    'filter_2': 0xe271, // image — 2, array, categorize, count, customize
    'filter_2_outlined':
        0xf05f, // [outline] image — 2, array, categorize, count, customize
    'filter_2_rounded':
        0xf74c, // [round] image — 2, array, categorize, count, customize
    'filter_2_sharp':
        0xe96d, // [sharp] image — 2, array, categorize, count, customize
    'filter_3': 0xe272, // image — 3, adjust, adjustment, bars, count
    'filter_3_outlined':
        0xf060, // [outline] image — 3, adjust, adjustment, bars, count
    'filter_3_rounded':
        0xf74d, // [round] image — 3, adjust, adjustment, bars, count
    'filter_3_sharp':
        0xe96e, // [sharp] image — 3, adjust, adjustment, bars, count
    'filter_4': 0xe273, // image — 4, adjust, choose, count, criteria
    'filter_4_outlined':
        0xf061, // [outline] image — 4, adjust, choose, count, criteria
    'filter_4_rounded':
        0xf74e, // [round] image — 4, adjust, choose, count, criteria
    'filter_4_sharp':
        0xe96f, // [sharp] image — 4, adjust, choose, count, criteria
    'filter_5': 0xe274, // image — 5, adjust, configure, constraints, count
    'filter_5_outlined':
        0xf062, // [outline] image — 5, adjust, configure, constraints, count
    'filter_5_rounded':
        0xf74f, // [round] image — 5, adjust, configure, constraints, count
    'filter_5_sharp':
        0xe970, // [sharp] image — 5, adjust, configure, constraints, count
    'filter_6':
        0xe275, // image — 6, apply filter, count, count filter, data filter
    'filter_6_outlined':
        0xf063, // [outline] image — 6, apply filter, count, count filter, data filter
    'filter_6_rounded':
        0xf750, // [round] image — 6, apply filter, count, count filter, data filter
    'filter_6_sharp':
        0xe971, // [sharp] image — 6, apply filter, count, count filter, data filter
    'filter_7': 0xe276, // image — 7, adjust, analysis, category, choose
    'filter_7_outlined':
        0xf064, // [outline] image — 7, adjust, analysis, category, choose
    'filter_7_rounded':
        0xf751, // [round] image — 7, adjust, analysis, category, choose
    'filter_7_sharp':
        0xe972, // [sharp] image — 7, adjust, analysis, category, choose
    'filter_8': 0xe277, // image — 8, adjust, categorize, constrain, criteria
    'filter_8_outlined':
        0xf065, // [outline] image — 8, adjust, categorize, constrain, criteria
    'filter_8_rounded':
        0xf752, // [round] image — 8, adjust, categorize, constrain, criteria
    'filter_8_sharp':
        0xe973, // [sharp] image — 8, adjust, categorize, constrain, criteria
    'filter_9': 0xe278, // image — 9, adjust, categories, counter, criteria
    'filter_9_outlined':
        0xf066, // [outline] image — 9, adjust, categories, counter, criteria
    'filter_9_plus': 0xe279, // image — +, 9, 9 plus, 9+, amount
    'filter_9_plus_outlined':
        0xf067, // [outline] image — +, 9, 9 plus, 9+, amount
    'filter_9_plus_rounded': 0xf753, // [round] image — +, 9, 9 plus, 9+, amount
    'filter_9_plus_sharp': 0xe974, // [sharp] image — +, 9, 9 plus, 9+, amount
    'filter_9_rounded':
        0xf754, // [round] image — 9, adjust, categories, counter, criteria
    'filter_9_sharp':
        0xe975, // [sharp] image — 9, adjust, categories, counter, criteria
    'filter_alt': 0xe27a, // action — adjust, arrange, choose, customize, edit
    'filter_alt_off':
        0xf0500, // action — alt, clear criteria, clear filter, clear selection, data filter
    'filter_alt_off_outlined':
        0xf05fa, // [outline] action — alt, clear criteria, clear filter, clear selection, data filter
    'filter_alt_off_rounded':
        0xf0319, // [round] action — alt, clear criteria, clear filter, clear selection, data filter
    'filter_alt_off_sharp':
        0xf040c, // [sharp] action — alt, clear criteria, clear filter, clear selection, data filter
    'filter_alt_outlined':
        0xf068, // [outline] action — adjust, arrange, choose, customize, edit
    'filter_alt_rounded':
        0xf755, // [round] action — adjust, arrange, choose, customize, edit
    'filter_alt_sharp':
        0xe976, // [sharp] action — adjust, arrange, choose, customize, edit
    'filter_b_and_w': 0xe27b, // image — and, apply, b, b&w, black
    'filter_b_and_w_outlined':
        0xf069, // [outline] image — and, apply, b, b&w, black
    'filter_b_and_w_rounded':
        0xf756, // [round] image — and, apply, b, b&w, black
    'filter_b_and_w_sharp': 0xe977, // [sharp] image — and, apply, b, b&w, black
    'filter_center_focus':
        0xe27c, // image — adjust, aiming, alignment, box, calibration
    'filter_center_focus_outlined':
        0xf06a, // [outline] image — adjust, aiming, alignment, box, calibration
    'filter_center_focus_rounded':
        0xf757, // [round] image — adjust, aiming, alignment, box, calibration
    'filter_center_focus_sharp':
        0xe978, // [sharp] image — adjust, aiming, alignment, box, calibration
    'filter_drama': 0xe27d, // image — atmosphere, cinematic, cloud, dark, drama
    'filter_drama_outlined':
        0xf06b, // [outline] image — atmosphere, cinematic, cloud, dark, drama
    'filter_drama_rounded':
        0xf758, // [round] image — atmosphere, cinematic, cloud, dark, drama
    'filter_drama_sharp':
        0xe979, // [sharp] image — atmosphere, cinematic, cloud, dark, drama
    'filter_frames':
        0xe27e, // image — albums, arrangement, boarders, camera, center
    'filter_frames_outlined':
        0xf06c, // [outline] image — albums, arrangement, boarders, camera, center
    'filter_frames_rounded':
        0xf759, // [round] image — albums, arrangement, boarders, camera, center
    'filter_frames_sharp':
        0xe97a, // [sharp] image — albums, arrangement, boarders, camera, center
    'filter_hdr': 0xe27f, // image — camera, earth, edit, editing, effect
    'filter_hdr_outlined':
        0xf06d, // [outline] image — camera, earth, edit, editing, effect
    'filter_hdr_rounded':
        0xf75a, // [round] image — camera, earth, edit, editing, effect
    'filter_hdr_sharp':
        0xe97b, // [sharp] image — camera, earth, edit, editing, effect
    'filter_list':
        0xe280, // content — arrange, bar, bar graph, bars, categorize
    'filter_list_alt':
        0xe281, // action — adjust, alternate, arrange, bars, categorize
    'filter_list_off': 0xf0501, // content — alt, bars, choices, clear, disable
    'filter_list_off_outlined':
        0xf05fb, // [outline] content — alt, bars, choices, clear, disable
    'filter_list_off_rounded':
        0xf031a, // [round] content — alt, bars, choices, clear, disable
    'filter_list_off_sharp':
        0xf040d, // [sharp] content — alt, bars, choices, clear, disable
    'filter_list_outlined':
        0xf06e, // [outline] content — arrange, bar, bar graph, bars, categorize
    'filter_list_rounded':
        0xf75b, // [round] content — arrange, bar, bar graph, bars, categorize
    'filter_list_sharp':
        0xe97c, // [sharp] content — arrange, bar, bar graph, bars, categorize
    'filter_none': 0xe282, // image — blank, clean, clear, empty, filter
    'filter_none_outlined':
        0xf06f, // [outline] image — blank, clean, clear, empty, filter
    'filter_none_rounded':
        0xf75c, // [round] image — blank, clean, clear, empty, filter
    'filter_none_sharp':
        0xe97d, // [sharp] image — blank, clean, clear, empty, filter
    'filter_outlined':
        0xf070, // [outline] image — adjustments, categorization, categorize, choices, collections
    'filter_rounded':
        0xf75d, // [round] image — adjustments, categorization, categorize, choices, collections
    'filter_sharp':
        0xe97e, // [sharp] image — adjustments, categorization, categorize, choices, collections
    'filter_tilt_shift':
        0xe283, // image — adjustment, aperture, blur, camera, center
    'filter_tilt_shift_outlined':
        0xf071, // [outline] image — adjustment, aperture, blur, camera, center
    'filter_tilt_shift_rounded':
        0xf75e, // [round] image — adjustment, aperture, blur, camera, center
    'filter_tilt_shift_sharp':
        0xe97f, // [sharp] image — adjustment, aperture, blur, camera, center
    'filter_vintage':
        0xe284, // image — abstract, adjust, bloom, blossom, camera
    'filter_vintage_outlined':
        0xf072, // [outline] image — abstract, adjust, bloom, blossom, camera
    'filter_vintage_rounded':
        0xf75f, // [round] image — abstract, adjust, bloom, blossom, camera
    'filter_vintage_sharp':
        0xe980, // [sharp] image — abstract, adjust, bloom, blossom, camera
    'find_in_page':
        0xe285, // action — content search, doc, document, document search, drive
    'find_in_page_outlined':
        0xf073, // [outline] action — content search, doc, document, document search, drive
    'find_in_page_rounded':
        0xf760, // [round] action — content search, doc, document, document search, drive
    'find_in_page_sharp':
        0xe981, // [sharp] action — content search, doc, document, document search, drive
    'find_replace':
        0xe286, // action — around, arrows, command, content, discover
    'find_replace_outlined':
        0xf074, // [outline] action — around, arrows, command, content, discover
    'find_replace_rounded':
        0xf761, // [round] action — around, arrows, command, content, discover
    'find_replace_sharp':
        0xe982, // [sharp] action — around, arrows, command, content, discover
    'fingerprint':
        0xe287, // action — access, authentication, authorized, biometric, circles
    'fingerprint_outlined':
        0xf075, // [outline] action — access, authentication, authorized, biometric, circles
    'fingerprint_rounded':
        0xf762, // [round] action — access, authentication, authorized, biometric, circles
    'fingerprint_sharp':
        0xe983, // [sharp] action — access, authentication, authorized, biometric, circles
    'fire_extinguisher':
        0xe288, // places — alarm, alert, cylinder, danger, device
    'fire_extinguisher_outlined':
        0xf076, // [outline] places — alarm, alert, cylinder, danger, device
    'fire_extinguisher_rounded':
        0xf763, // [round] places — alarm, alert, cylinder, danger, device
    'fire_extinguisher_sharp':
        0xe984, // [sharp] places — alarm, alert, cylinder, danger, device
    'fire_hydrant': 0xe289, // Maps — 911, access, city, connection, department
    'fire_hydrant_alt': 0xf07a1, // maps
    'fire_hydrant_alt_outlined': 0xf06f1, // [outline] maps
    'fire_hydrant_alt_rounded': 0xf07f9, // [round] maps
    'fire_hydrant_alt_sharp': 0xf0749, // [sharp] maps
    'fire_truck': 0xf07a2, // maps — accident, aid, alarm, alert, automotive
    'fire_truck_outlined':
        0xf06f2, // [outline] maps — accident, aid, alarm, alert, automotive
    'fire_truck_rounded':
        0xf07fa, // [round] maps — accident, aid, alarm, alert, automotive
    'fire_truck_sharp':
        0xf074a, // [sharp] maps — accident, aid, alarm, alert, automotive
    'fireplace':
        0xe28a, // social — barbecue, burning, camping, chimney, comfort
    'fireplace_outlined':
        0xf077, // [outline] social — barbecue, burning, camping, chimney, comfort
    'fireplace_rounded':
        0xf764, // [round] social — barbecue, burning, camping, chimney, comfort
    'fireplace_sharp':
        0xe985, // [sharp] social — barbecue, burning, camping, chimney, comfort
    'first_page': 0xe28b, // navigation — arrow, back, beginning, book, caret
    'first_page_outlined':
        0xf078, // [outline] navigation — arrow, back, beginning, book, caret
    'first_page_rounded':
        0xf765, // [round] navigation — arrow, back, beginning, book, caret
    'first_page_sharp':
        0xe986, // [sharp] navigation — arrow, back, beginning, book, caret
    'fit_screen':
        0xe28c, // action — adjust, arrows, aspect ratio, boundary, box
    'fit_screen_outlined':
        0xf079, // [outline] action — adjust, arrows, aspect ratio, boundary, box
    'fit_screen_rounded':
        0xf766, // [round] action — adjust, arrows, aspect ratio, boundary, box
    'fit_screen_sharp':
        0xe987, // [sharp] action — adjust, arrows, aspect ratio, boundary, box
    'fitbit': 0xf0502, // social — abstract, activity, athlete, athletic, brand
    'fitbit_outlined':
        0xf05fc, // [outline] social — abstract, activity, athlete, athletic, brand
    'fitbit_rounded':
        0xf031b, // [round] social — abstract, activity, athlete, athletic, brand
    'fitbit_sharp':
        0xf040e, // [sharp] social — abstract, activity, athlete, athletic, brand
    'fitness_center':
        0xe28d, // places — active, athlete, athletics, barbell, bodybuilding
    'fitness_center_outlined':
        0xf07a, // [outline] places — active, athlete, athletics, barbell, bodybuilding
    'fitness_center_rounded':
        0xf767, // [round] places — active, athlete, athletics, barbell, bodybuilding
    'fitness_center_sharp':
        0xe988, // [sharp] places — active, athlete, athletics, barbell, bodybuilding
    'five_g': 0xe024, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_g_outlined':
        0xee16, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_g_rounded':
        0xf503, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_g_sharp':
        0xe724, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k': 0xe025, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_outlined':
        0xee17, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_plus': 0xe026, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_plus_outlined':
        0xee18, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_plus_rounded':
        0xf504, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_plus_sharp':
        0xe725, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_rounded':
        0xf505, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_k_sharp':
        0xe726, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_mp': 0xe027, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_mp_outlined':
        0xee19, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_mp_rounded':
        0xf506, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'five_mp_sharp':
        0xe727, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'flag':
        0xe28e, // content — achievement, banner, bookmark, country, destination
    'flag_circle':
        0xf0503, // content — circle, country, destination, direction, emblem
    'flag_circle_outlined':
        0xf05fd, // [outline] content — circle, country, destination, direction, emblem
    'flag_circle_rounded':
        0xf031c, // [round] content — circle, country, destination, direction, emblem
    'flag_circle_sharp':
        0xf040f, // [sharp] content — circle, country, destination, direction, emblem
    'flag_outlined':
        0xf07b, // [outline] content — achievement, banner, bookmark, country, destination
    'flag_rounded':
        0xf768, // [round] content — achievement, banner, bookmark, country, destination
    'flag_sharp':
        0xe989, // [sharp] content — achievement, banner, bookmark, country, destination
    'flaky': 0xe28f, // action — approve, check, close, close menu, collapse
    'flaky_outlined':
        0xf07c, // [outline] action — approve, check, close, close menu, collapse
    'flaky_rounded':
        0xf769, // [round] action — approve, check, close, close menu, collapse
    'flaky_sharp':
        0xe98a, // [sharp] action — approve, check, close, close menu, collapse
    'flare': 0xe290, // image — blast, bright, burst, burst of light, camera
    'flare_outlined':
        0xf07d, // [outline] image — blast, bright, burst, burst of light, camera
    'flare_rounded':
        0xf76a, // [round] image — blast, bright, burst, burst of light, camera
    'flare_sharp':
        0xe98b, // [sharp] image — blast, bright, burst, burst of light, camera
    'flash_auto': 0xe291, // image — a, auto, auto mode, automatic, bolt
    'flash_auto_outlined':
        0xf07e, // [outline] image — a, auto, auto mode, automatic, bolt
    'flash_auto_rounded':
        0xf76b, // [round] image — a, auto, auto mode, automatic, bolt
    'flash_auto_sharp':
        0xe98c, // [sharp] image — a, auto, auto mode, automatic, bolt
    'flash_off':
        0xe292, // image — bolt, camera control, camera flash, camera option, camera setting
    'flash_off_outlined':
        0xf07f, // [outline] image — bolt, camera control, camera flash, camera option, camera setting
    'flash_off_rounded':
        0xf76c, // [round] image — bolt, camera control, camera flash, camera option, camera setting
    'flash_off_sharp':
        0xe98d, // [sharp] image — bolt, camera control, camera flash, camera option, camera setting
    'flash_on': 0xe293, // image — activate, alert, bolt, bright, camera
    'flash_on_outlined':
        0xf080, // [outline] image — activate, alert, bolt, bright, camera
    'flash_on_rounded':
        0xf76d, // [round] image — activate, alert, bolt, bright, camera
    'flash_on_sharp':
        0xe98e, // [sharp] image — activate, alert, bolt, bright, camera
    'flashlight_off':
        0xe294, // device — beam off, brightness., dark, deactivate, device
    'flashlight_off_outlined':
        0xf081, // [outline] device — beam off, brightness., dark, deactivate, device
    'flashlight_off_rounded':
        0xf76e, // [round] device — beam off, brightness., dark, deactivate, device
    'flashlight_off_sharp':
        0xe98f, // [sharp] device — beam off, brightness., dark, deactivate, device
    'flashlight_on':
        0xe295, // device — activated, beam, bright, camping, circle
    'flashlight_on_outlined':
        0xf082, // [outline] device — activated, beam, bright, camping, circle
    'flashlight_on_rounded':
        0xf76f, // [round] device — activated, beam, bright, camping, circle
    'flashlight_on_sharp':
        0xe990, // [sharp] device — activated, beam, bright, camping, circle
    'flatware': 0xe296, // search — cafe, cafeteria, catering, cooking, cutlery
    'flatware_outlined':
        0xf083, // [outline] search — cafe, cafeteria, catering, cooking, cutlery
    'flatware_rounded':
        0xf770, // [round] search — cafe, cafeteria, catering, cooking, cutlery
    'flatware_sharp':
        0xe991, // [sharp] search — cafe, cafeteria, catering, cooking, cutlery
    'flight': 0xe297, // maps — ai, air, air travel, aircraft, airplane
    'flight_class':
        0xf0504, // maps — aerial, air, air travel, aircraft, airline
    'flight_class_outlined':
        0xf05fe, // [outline] maps — aerial, air, air travel, aircraft, airline
    'flight_class_rounded':
        0xf031d, // [round] maps — aerial, air, air travel, aircraft, airline
    'flight_class_sharp':
        0xf0410, // [sharp] maps — aerial, air, air travel, aircraft, airline
    'flight_land':
        0xe298, // action — air, aircraft, airplane, airplanes, airport
    'flight_land_outlined':
        0xf084, // [outline] action — air, aircraft, airplane, airplanes, airport
    'flight_land_rounded':
        0xf771, // [round] action — air, aircraft, airplane, airplanes, airport
    'flight_land_sharp':
        0xe992, // [sharp] action — air, aircraft, airplane, airplanes, airport
    'flight_outlined':
        0xf085, // [outline] maps — ai, air, air travel, aircraft, airplane
    'flight_rounded':
        0xf772, // [round] maps — ai, air, air travel, aircraft, airplane
    'flight_sharp':
        0xe993, // [sharp] maps — ai, air, air travel, aircraft, airplane
    'flight_takeoff':
        0xe299, // action — air, air transport, air travel, aircraft, airplane
    'flight_takeoff_outlined':
        0xf086, // [outline] action — air, air transport, air travel, aircraft, airplane
    'flight_takeoff_rounded':
        0xf773, // [round] action — air, air transport, air travel, aircraft, airplane
    'flight_takeoff_sharp':
        0xe994, // [sharp] action — air, air transport, air travel, aircraft, airplane
    'flip': 0xe29a, // image — adjust, arrow, change, change direction, commands
    'flip_camera_android':
        0xe29b, // image — android, arrows, back camera, camera, camera direction
    'flip_camera_android_outlined':
        0xf087, // [outline] image — android, arrows, back camera, camera, camera direction
    'flip_camera_android_rounded':
        0xf774, // [round] image — android, arrows, back camera, camera, camera direction
    'flip_camera_android_sharp':
        0xe995, // [sharp] image — android, arrows, back camera, camera, camera direction
    'flip_camera_ios':
        0xe29c, // image — android, arrows, camera, camera toggle, capture
    'flip_camera_ios_outlined':
        0xf088, // [outline] image — android, arrows, camera, camera toggle, capture
    'flip_camera_ios_rounded':
        0xf775, // [round] image — android, arrows, camera, camera toggle, capture
    'flip_camera_ios_sharp':
        0xe996, // [sharp] image — android, arrows, camera, camera toggle, capture
    'flip_outlined':
        0xf089, // [outline] image — adjust, arrow, change, change direction, commands
    'flip_rounded':
        0xf776, // [round] image — adjust, arrow, change, change direction, commands
    'flip_sharp':
        0xe997, // [sharp] image — adjust, arrow, change, change direction, commands
    'flip_to_back':
        0xe29d, // action — arrange, arrangement, back, bring forward, bring to front
    'flip_to_back_outlined':
        0xf08a, // [outline] action — arrange, arrangement, back, bring forward, bring to front
    'flip_to_back_rounded':
        0xf777, // [round] action — arrange, arrangement, back, bring forward, bring to front
    'flip_to_back_sharp':
        0xe998, // [sharp] action — arrange, arrangement, back, bring forward, bring to front
    'flip_to_front':
        0xe29e, // action — arrange, arrangement, ascend, back, bring forward
    'flip_to_front_outlined':
        0xf08b, // [outline] action — arrange, arrangement, ascend, back, bring forward
    'flip_to_front_rounded':
        0xf778, // [round] action — arrange, arrangement, ascend, back, bring forward
    'flip_to_front_sharp':
        0xe999, // [sharp] action — arrange, arrangement, ascend, back, bring forward
    'flood':
        0xf07a3, // social — abstract waves, alert, climate, climate change, crisis
    'flood_outlined':
        0xf06f3, // [outline] social — abstract waves, alert, climate, climate change, crisis
    'flood_rounded':
        0xf07fb, // [round] social — abstract waves, alert, climate, climate change, crisis
    'flood_sharp':
        0xf074b, // [sharp] social — abstract waves, alert, climate, climate change, crisis
    'flourescent': 0xf0865,
    'flourescent_outlined': 0xf08a7,
    'flourescent_rounded': 0xf0889,
    'flourescent_sharp': 0xf0840,
    'fluorescent':
        0xf0865, // device — adjustments, bright, brightness, camera, effects
    'fluorescent_outlined':
        0xf08a7, // [outline] device — adjustments, bright, brightness, camera, effects
    'fluorescent_rounded':
        0xf0889, // [round] device — adjustments, bright, brightness, camera, effects
    'fluorescent_sharp':
        0xf0840, // [sharp] device — adjustments, bright, brightness, camera, effects
    'flutter_dash':
        0xe2a0, // action — abstract, animal, app development, bird, brand
    'flutter_dash_outlined':
        0xf08d, // [outline] action — abstract, animal, app development, bird, brand
    'flutter_dash_rounded':
        0xf77a, // [round] action — abstract, animal, app development, bird, brand
    'flutter_dash_sharp':
        0xe99b, // [sharp] action — abstract, animal, app development, bird, brand
    'fmd_bad': 0xe2a1, // device — !, address, alert, attention, bad
    'fmd_bad_outlined':
        0xf08e, // [outline] device — !, address, alert, attention, bad
    'fmd_bad_rounded':
        0xf77b, // [round] device — !, address, alert, attention, bad
    'fmd_bad_sharp':
        0xe99c, // [sharp] device — !, address, alert, attention, bad
    'fmd_good':
        0xe2a2, // device — address, area, current location, destination, direction
    'fmd_good_outlined':
        0xf08f, // [outline] device — address, area, current location, destination, direction
    'fmd_good_rounded':
        0xf77c, // [round] device — address, area, current location, destination, direction
    'fmd_good_sharp':
        0xe99d, // [sharp] device — address, area, current location, destination, direction
    'foggy': 0xf0505, // home — abstract, atmospheric, climate, cloud, clouds
    'folder':
        0xe2a3, // file — administration, archive, browse, business, category
    'folder_copy': 0xf0506, // file — archive, backup, clone, content, copy
    'folder_copy_outlined':
        0xf05ff, // [outline] file — archive, backup, clone, content, copy
    'folder_copy_rounded':
        0xf031e, // [round] file — archive, backup, clone, content, copy
    'folder_copy_sharp':
        0xf0411, // [sharp] file — archive, backup, clone, content, copy
    'folder_delete':
        0xf0507, // file — administration, archive, bin, business, can
    'folder_delete_outlined':
        0xf0600, // [outline] file — administration, archive, bin, business, can
    'folder_delete_rounded':
        0xf031f, // [round] file — administration, archive, bin, business, can
    'folder_delete_sharp':
        0xf0412, // [sharp] file — administration, archive, bin, business, can
    'folder_off':
        0xf0508, // file — access denied, block, blocked, close folder, data folder off
    'folder_off_outlined':
        0xf0601, // [outline] file — access denied, block, blocked, close folder, data folder off
    'folder_off_rounded':
        0xf0320, // [round] file — access denied, block, blocked, close folder, data folder off
    'folder_off_sharp':
        0xf0413, // [sharp] file — access denied, block, blocked, close folder, data folder off
    'folder_open':
        0xe2a4, // file — access, archive, browse, computer, container
    'folder_open_outlined':
        0xf090, // [outline] file — access, archive, browse, computer, container
    'folder_open_rounded':
        0xf77d, // [round] file — access, archive, browse, computer, container
    'folder_open_sharp':
        0xe99e, // [sharp] file — access, archive, browse, computer, container
    'folder_outlined':
        0xf091, // [outline] file — administration, archive, browse, business, category
    'folder_rounded':
        0xf77e, // [round] file — administration, archive, browse, business, category
    'folder_shared':
        0xe2a5, // file — access, account, backup, cloud, collaboration
    'folder_shared_outlined':
        0xf092, // [outline] file — access, account, backup, cloud, collaboration
    'folder_shared_rounded':
        0xf77f, // [round] file — access, account, backup, cloud, collaboration
    'folder_shared_sharp':
        0xe99f, // [sharp] file — access, account, backup, cloud, collaboration
    'folder_sharp':
        0xe9a0, // [sharp] file — administration, archive, browse, business, category
    'folder_special':
        0xe2a6, // notification — archive, bookmark, directory, doc, document
    'folder_special_outlined':
        0xf093, // [outline] notification — archive, bookmark, directory, doc, document
    'folder_special_rounded':
        0xf780, // [round] notification — archive, bookmark, directory, doc, document
    'folder_special_sharp':
        0xe9a1, // [sharp] notification — archive, bookmark, directory, doc, document
    'folder_zip':
        0xf0509, // file — archive, archive file, compress, compressed file, computer
    'folder_zip_outlined':
        0xf0602, // [outline] file — archive, archive file, compress, compressed file, computer
    'folder_zip_rounded':
        0xf0321, // [round] file — archive, archive file, compress, compressed file, computer
    'folder_zip_sharp':
        0xf0414, // [sharp] file — archive, archive file, compress, compressed file, computer
    'follow_the_signs':
        0xe2a7, // social — arrow, body, crossroads, destination, direction
    'follow_the_signs_outlined':
        0xf094, // [outline] social — arrow, body, crossroads, destination, direction
    'follow_the_signs_rounded':
        0xf781, // [round] social — arrow, body, crossroads, destination, direction
    'follow_the_signs_sharp':
        0xe9a2, // [sharp] social — arrow, body, crossroads, destination, direction
    'font_download': 0xe2a8, // content — A, acquire, alphabet, arrow, character
    'font_download_off':
        0xe2a9, // content — access denied, alphabet, blocked, cancel download, character
    'font_download_off_outlined':
        0xf095, // [outline] content — access denied, alphabet, blocked, cancel download, character
    'font_download_off_rounded':
        0xf782, // [round] content — access denied, alphabet, blocked, cancel download, character
    'font_download_off_sharp':
        0xe9a3, // [sharp] content — access denied, alphabet, blocked, cancel download, character
    'font_download_outlined':
        0xf096, // [outline] content — A, acquire, alphabet, arrow, character
    'font_download_rounded':
        0xf783, // [round] content — A, acquire, alphabet, arrow, character
    'font_download_sharp':
        0xe9a4, // [sharp] content — A, acquire, alphabet, arrow, character
    'food_bank': 0xe2aa, // places — access, aid, architecture, assistance, bank
    'food_bank_outlined':
        0xf097, // [outline] places — access, aid, architecture, assistance, bank
    'food_bank_rounded':
        0xf784, // [round] places — access, aid, architecture, assistance, bank
    'food_bank_sharp':
        0xe9a5, // [sharp] places — access, aid, architecture, assistance, bank
    'forest':
        0xf050a, // maps — abstract, adventure, destination, discovery, earth
    'forest_outlined':
        0xf0603, // [outline] maps — abstract, adventure, destination, discovery, earth
    'forest_rounded':
        0xf0322, // [round] maps — abstract, adventure, destination, discovery, earth
    'forest_sharp':
        0xf0415, // [sharp] maps — abstract, adventure, destination, discovery, earth
    'fork_left':
        0xf050b, // maps — alternative, arrow, arrows, branch left, branching path
    'fork_left_outlined':
        0xf0604, // [outline] maps — alternative, arrow, arrows, branch left, branching path
    'fork_left_rounded':
        0xf0323, // [round] maps — alternative, arrow, arrows, branch left, branching path
    'fork_left_sharp':
        0xf0416, // [sharp] maps — alternative, arrow, arrows, branch left, branching path
    'fork_right':
        0xf050c, // maps — arrow, arrow right, arrows, branch right, curve right
    'fork_right_outlined':
        0xf0605, // [outline] maps — arrow, arrow right, arrows, branch right, curve right
    'fork_right_rounded':
        0xf0324, // [round] maps — arrow, arrow right, arrows, branch right, curve right
    'fork_right_sharp':
        0xf0417, // [sharp] maps — arrow, arrow right, arrows, branch right, curve right
    'forklift':
        0xf0866, // hardware — automotive, cargo, carry, construction, delivery
    'format_align_center':
        0xe2ab, // editor — align, align horizontal, align middle, alignment, center
    'format_align_center_outlined':
        0xf098, // [outline] editor — align, align horizontal, align middle, alignment, center
    'format_align_center_rounded':
        0xf785, // [round] editor — align, align horizontal, align middle, alignment, center
    'format_align_center_sharp':
        0xe9a6, // [sharp] editor — align, align horizontal, align middle, alignment, center
    'format_align_justify':
        0xe2ac, // editor — adjust, align, alignment, arrange, blocks of text
    'format_align_justify_outlined':
        0xf099, // [outline] editor — adjust, align, alignment, arrange, blocks of text
    'format_align_justify_rounded':
        0xf786, // [round] editor — adjust, align, alignment, arrange, blocks of text
    'format_align_justify_sharp':
        0xe9a7, // [sharp] editor — adjust, align, alignment, arrange, blocks of text
    'format_align_left':
        0xe2ad, // editor — align, align document, align left, alignment, doc
    'format_align_left_outlined':
        0xf09a, // [outline] editor — align, align document, align left, alignment, doc
    'format_align_left_rounded':
        0xf787, // [round] editor — align, align document, align left, alignment, doc
    'format_align_left_sharp':
        0xe9a8, // [sharp] editor — align, align document, align left, alignment, doc
    'format_align_right':
        0xe2ae, // editor — adjust text, align, align right, alignment, doc
    'format_align_right_outlined':
        0xf09b, // [outline] editor — adjust text, align, align right, alignment, doc
    'format_align_right_rounded':
        0xf788, // [round] editor — adjust text, align, align right, alignment, doc
    'format_align_right_sharp':
        0xe9a9, // [sharp] editor — adjust text, align, align right, alignment, doc
    'format_bold': 0xe2af, // editor — B, alphabet, b, bold, character
    'format_bold_outlined':
        0xf09c, // [outline] editor — B, alphabet, b, bold, character
    'format_bold_rounded':
        0xf789, // [round] editor — B, alphabet, b, bold, character
    'format_bold_sharp':
        0xe9aa, // [sharp] editor — B, alphabet, b, bold, character
    'format_clear': 0xe2b0, // editor — T, alphabet, brush, character, clean
    'format_clear_outlined':
        0xf09d, // [outline] editor — T, alphabet, brush, character, clean
    'format_clear_rounded':
        0xf78a, // [round] editor — T, alphabet, brush, character, clean
    'format_clear_sharp':
        0xe9ab, // [sharp] editor — T, alphabet, brush, character, clean
    'format_color_fill': 0xe2b1, // editor — alter, apply, area, art, background
    'format_color_fill_outlined':
        0xf09e, // [outline] editor — alter, apply, area, art, background
    'format_color_fill_rounded':
        0xf78b, // [round] editor — alter, apply, area, art, background
    'format_color_fill_sharp':
        0xe9ac, // [sharp] editor — alter, apply, area, art, background
    'format_color_reset':
        0xe2b2, // editor — and, angled line, art, choose color, circle
    'format_color_reset_outlined':
        0xf09f, // [outline] editor — and, angled line, art, choose color, circle
    'format_color_reset_rounded':
        0xf78c, // [round] editor — and, angled line, art, choose color, circle
    'format_color_reset_sharp':
        0xe9ad, // [sharp] editor — and, angled line, art, choose color, circle
    'format_color_text': 0xe2b3, // editor — ab, abc, brush, change color, color
    'format_color_text_outlined':
        0xf0a0, // [outline] editor — ab, abc, brush, change color, color
    'format_color_text_rounded':
        0xf78d, // [round] editor — ab, abc, brush, change color, color
    'format_color_text_sharp':
        0xe9ae, // [sharp] editor — ab, abc, brush, change color, color
    'format_indent_decrease':
        0xe2b4, // editor — align, alignment, alignment control, decrease, decrease indent
    'format_indent_decrease_outlined':
        0xf0a1, // [outline] editor — align, alignment, alignment control, decrease, decrease indent
    'format_indent_decrease_rounded':
        0xf78e, // [round] editor — align, alignment, alignment control, decrease, decrease indent
    'format_indent_decrease_sharp':
        0xe9af, // [sharp] editor — align, alignment, alignment control, decrease, decrease indent
    'format_indent_increase':
        0xe2b5, // editor — align, alignment, block quote, content creation, doc
    'format_indent_increase_outlined':
        0xf0a2, // [outline] editor — align, alignment, block quote, content creation, doc
    'format_indent_increase_rounded':
        0xf78f, // [round] editor — align, alignment, block quote, content creation, doc
    'format_indent_increase_sharp':
        0xe9b0, // [sharp] editor — align, alignment, block quote, content creation, doc
    'format_italic': 0xe2b6, // editor — a, abc, adjust, alphabet, angle
    'format_italic_outlined':
        0xf0a3, // [outline] editor — a, abc, adjust, alphabet, angle
    'format_italic_rounded':
        0xf790, // [round] editor — a, abc, adjust, alphabet, angle
    'format_italic_sharp':
        0xe9b1, // [sharp] editor — a, abc, adjust, alphabet, angle
    'format_line_spacing':
        0xe2b7, // editor — adjust spacing, align, alignment, arrows, decrease spacing
    'format_line_spacing_outlined':
        0xf0a4, // [outline] editor — adjust spacing, align, alignment, arrows, decrease spacing
    'format_line_spacing_rounded':
        0xf791, // [round] editor — adjust spacing, align, alignment, arrows, decrease spacing
    'format_line_spacing_sharp':
        0xe9b2, // [sharp] editor — adjust spacing, align, alignment, arrows, decrease spacing
    'format_list_bulleted':
        0xe2b8, // editor — align, alignment, arrangement, bullet list, bulleted
    'format_list_bulleted_add':
        0xf0867, // editor — +, add, align, alignment, append
    'format_list_bulleted_outlined':
        0xf0a5, // [outline] editor — align, alignment, arrangement, bullet list, bulleted
    'format_list_bulleted_rounded':
        0xf792, // [round] editor — align, alignment, arrangement, bullet list, bulleted
    'format_list_bulleted_sharp':
        0xe9b3, // [sharp] editor — align, alignment, arrangement, bullet list, bulleted
    'format_list_numbered':
        0xe2b9, // editor — align, alignment, arrangement, bullet points, digit
    'format_list_numbered_outlined':
        0xf0a6, // [outline] editor — align, alignment, arrangement, bullet points, digit
    'format_list_numbered_rounded':
        0xf793, // [round] editor — align, alignment, arrangement, bullet points, digit
    'format_list_numbered_rtl':
        0xe2ba, // editor — align, alignment, arabic, bulleted list, content
    'format_list_numbered_rtl_outlined':
        0xf0a7, // [outline] editor — align, alignment, arabic, bulleted list, content
    'format_list_numbered_rtl_rounded':
        0xf794, // [round] editor — align, alignment, arabic, bulleted list, content
    'format_list_numbered_rtl_sharp':
        0xe9b4, // [sharp] editor — align, alignment, arabic, bulleted list, content
    'format_list_numbered_sharp':
        0xe9b5, // [sharp] editor — align, alignment, arrangement, bullet points, digit
    'format_overline':
        0xf050d, // file — alphabet, character, character formatting, doc, document
    'format_overline_outlined':
        0xf0606, // [outline] file — alphabet, character, character formatting, doc, document
    'format_overline_rounded':
        0xf0325, // [round] file — alphabet, character, character formatting, doc, document
    'format_overline_sharp':
        0xf0418, // [sharp] file — alphabet, character, character formatting, doc, document
    'format_paint': 0xe2bb, // editor — adjust, adjustment, art, artist, brush
    'format_paint_outlined':
        0xf0a8, // [outline] editor — adjust, adjustment, art, artist, brush
    'format_paint_rounded':
        0xf795, // [round] editor — adjust, adjustment, art, artist, brush
    'format_paint_sharp':
        0xe9b6, // [sharp] editor — adjust, adjustment, art, artist, brush
    'format_quote':
        0xe2bc, // editor — block quote, citation, citation format, closing quote, comment
    'format_quote_outlined':
        0xf0a9, // [outline] editor — block quote, citation, citation format, closing quote, comment
    'format_quote_rounded':
        0xf796, // [round] editor — block quote, citation, citation format, closing quote, comment
    'format_quote_sharp':
        0xe9b7, // [sharp] editor — block quote, citation, citation format, closing quote, comment
    'format_shapes':
        0xe2bd, // editor — align, alphabet, arrange, character, circle
    'format_shapes_outlined':
        0xf0aa, // [outline] editor — align, alphabet, arrange, character, circle
    'format_shapes_rounded':
        0xf797, // [round] editor — align, alphabet, arrange, character, circle
    'format_shapes_sharp':
        0xe9b8, // [sharp] editor — align, alphabet, arrange, character, circle
    'format_size':
        0xe2be, // editor — a a, alphabet, alphabet size, big a little a, character
    'format_size_outlined':
        0xf0ab, // [outline] editor — a a, alphabet, alphabet size, big a little a, character
    'format_size_rounded':
        0xf798, // [round] editor — a a, alphabet, alphabet size, big a little a, character
    'format_size_sharp':
        0xe9b9, // [sharp] editor — a a, alphabet, alphabet size, big a little a, character
    'format_strikethrough':
        0xe2bf, // editor — alphabet, cancel, character, cross out, crossed
    'format_strikethrough_outlined':
        0xf0ac, // [outline] editor — alphabet, cancel, character, cross out, crossed
    'format_strikethrough_rounded':
        0xf799, // [round] editor — alphabet, cancel, character, cross out, crossed
    'format_strikethrough_sharp':
        0xe9ba, // [sharp] editor — alphabet, cancel, character, cross out, crossed
    'format_textdirection_l_to_r':
        0xe2c0, // editor — align, alignment, bidirectional text, direction, doc
    'format_textdirection_l_to_r_outlined':
        0xf0ad, // [outline] editor — align, alignment, bidirectional text, direction, doc
    'format_textdirection_l_to_r_rounded':
        0xf79a, // [round] editor — align, alignment, bidirectional text, direction, doc
    'format_textdirection_l_to_r_sharp':
        0xe9bb, // [sharp] editor — align, alignment, bidirectional text, direction, doc
    'format_textdirection_r_to_l':
        0xe2c1, // editor — align, alignment, alignment direction, bidirectional, bidirectional text
    'format_textdirection_r_to_l_outlined':
        0xf0ae, // [outline] editor — align, alignment, alignment direction, bidirectional, bidirectional text
    'format_textdirection_r_to_l_rounded':
        0xf79b, // [round] editor — align, alignment, alignment direction, bidirectional, bidirectional text
    'format_textdirection_r_to_l_sharp':
        0xe9bc, // [sharp] editor — align, alignment, alignment direction, bidirectional, bidirectional text
    'format_underline': 0xe2c2,
    'format_underline_outlined': 0xf0af,
    'format_underline_rounded': 0xf79c,
    'format_underline_sharp': 0xe9bd,
    'format_underlined':
        0xe2c2, // editor — alphabet, character, decoration, doc, document
    'format_underlined_outlined':
        0xf0af, // [outline] editor — alphabet, character, decoration, doc, document
    'format_underlined_rounded':
        0xf79c, // [round] editor — alphabet, character, decoration, doc, document
    'format_underlined_sharp':
        0xe9bd, // [sharp] editor — alphabet, character, decoration, doc, document
    'fort':
        0xf050e, // maps — ancient, architecture, battlements, building, castle
    'fort_outlined':
        0xf0607, // [outline] maps — ancient, architecture, battlements, building, castle
    'fort_rounded':
        0xf0326, // [round] maps — ancient, architecture, battlements, building, castle
    'fort_sharp':
        0xf0419, // [sharp] maps — ancient, architecture, battlements, building, castle
    'forum': 0xe2c3, // communication — answers, bubble, chat, comment, comments
    'forum_outlined':
        0xf0b0, // [outline] communication — answers, bubble, chat, comment, comments
    'forum_rounded':
        0xf79d, // [round] communication — answers, bubble, chat, comment, comments
    'forum_sharp':
        0xe9be, // [sharp] communication — answers, bubble, chat, comment, comments
    'forward':
        0xe2c4, // content — arrow, communication, content sharing, forward, google plus
    'forward_10': 0xe2c5, // av — 10, 10 seconds, advance, arrow, audio
    'forward_10_outlined':
        0xf0b1, // [outline] av — 10, 10 seconds, advance, arrow, audio
    'forward_10_rounded':
        0xf79e, // [round] av — 10, 10 seconds, advance, arrow, audio
    'forward_10_sharp':
        0xe9bf, // [sharp] av — 10, 10 seconds, advance, arrow, audio
    'forward_30': 0xe2c6, // av — 30, 30 seconds, advance, arc, arrow
    'forward_30_outlined':
        0xf0b2, // [outline] av — 30, 30 seconds, advance, arc, arrow
    'forward_30_rounded':
        0xf79f, // [round] av — 30, 30 seconds, advance, arc, arrow
    'forward_30_sharp':
        0xe9c0, // [sharp] av — 30, 30 seconds, advance, arc, arrow
    'forward_5': 0xe2c7, // av — 10, 5, 5 seconds, advance, arrow
    'forward_5_outlined':
        0xf0b3, // [outline] av — 10, 5, 5 seconds, advance, arrow
    'forward_5_rounded':
        0xf7a0, // [round] av — 10, 5, 5 seconds, advance, arrow
    'forward_5_sharp': 0xe9c1, // [sharp] av — 10, 5, 5 seconds, advance, arrow
    'forward_outlined':
        0xf0b4, // [outline] content — arrow, communication, content sharing, forward, google plus
    'forward_rounded':
        0xf7a1, // [round] content — arrow, communication, content sharing, forward, google plus
    'forward_sharp':
        0xe9c2, // [sharp] content — arrow, communication, content sharing, forward, google plus
    'forward_to_inbox':
        0xe2c8, // communication — arrow, arrows, communication, correspondence, delivery
    'forward_to_inbox_outlined':
        0xf0b5, // [outline] communication — arrow, arrows, communication, correspondence, delivery
    'forward_to_inbox_rounded':
        0xf7a2, // [round] communication — arrow, arrows, communication, correspondence, delivery
    'forward_to_inbox_sharp':
        0xe9c3, // [sharp] communication — arrow, arrows, communication, correspondence, delivery
    'foundation':
        0xe2c9, // places — architectural element, architecture, base, basis, beginning
    'foundation_outlined':
        0xf0b6, // [outline] places — architectural element, architecture, base, basis, beginning
    'foundation_rounded':
        0xf7a3, // [round] places — architectural element, architecture, base, basis, beginning
    'foundation_sharp':
        0xe9c4, // [sharp] places — architectural element, architecture, base, basis, beginning
    'four_g_mobiledata':
        0xe01f, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_mobiledata_outlined':
        0xee11, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_mobiledata_rounded':
        0xf4fe, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_mobiledata_sharp':
        0xe71f, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_plus_mobiledata':
        0xe020, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_plus_mobiledata_outlined':
        0xee12, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_plus_mobiledata_rounded':
        0xf4ff, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_g_plus_mobiledata_sharp':
        0xe720, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k': 0xe021, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_outlined':
        0xee13, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_plus': 0xe022, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_plus_outlined':
        0xee14, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_plus_rounded':
        0xf500, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_plus_sharp':
        0xe721, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_rounded':
        0xf501, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_k_sharp':
        0xe722, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_mp': 0xe023, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_mp_outlined':
        0xee15, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_mp_rounded':
        0xf502, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'four_mp_sharp':
        0xe723, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'fourteen_mp': 0xe005, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'fourteen_mp_outlined':
        0xedf7, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'fourteen_mp_rounded':
        0xf4e4, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'fourteen_mp_sharp':
        0xe705, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'free_breakfast':
        0xe2ca, // places — beverage, break, breakfast, cafe, caffeine
    'free_breakfast_outlined':
        0xf0b7, // [outline] places — beverage, break, breakfast, cafe, caffeine
    'free_breakfast_rounded':
        0xf7a4, // [round] places — beverage, break, breakfast, cafe, caffeine
    'free_breakfast_sharp':
        0xe9c5, // [sharp] places — beverage, break, breakfast, cafe, caffeine
    'free_cancellation':
        0xf050f, // action — abort, approve, back out, block, calendar
    'free_cancellation_outlined':
        0xf0608, // [outline] action — abort, approve, back out, block, calendar
    'free_cancellation_rounded':
        0xf0327, // [round] action — abort, approve, back out, block, calendar
    'free_cancellation_sharp':
        0xf041a, // [sharp] action — abort, approve, back out, block, calendar
    'front_hand':
        0xf0510, // social — accessibility, alert, anatomy, body part, communication
    'front_hand_outlined':
        0xf0609, // [outline] social — accessibility, alert, anatomy, body part, communication
    'front_hand_rounded':
        0xf0328, // [round] social — accessibility, alert, anatomy, body part, communication
    'front_hand_sharp':
        0xf041b, // [sharp] social — accessibility, alert, anatomy, body part, communication
    'front_loader':
        0xf0868, // hardware — bucket loader, building, carry, construction, construction vehicle
    'fullscreen':
        0xe2cb, // navigation — adjust, aspect ratio, big, cinema mode, display
    'fullscreen_exit':
        0xe2cc, // navigation — adjust, arrows, cinema, close, collapse
    'fullscreen_exit_outlined':
        0xf0b8, // [outline] navigation — adjust, arrows, cinema, close, collapse
    'fullscreen_exit_rounded':
        0xf7a5, // [round] navigation — adjust, arrows, cinema, close, collapse
    'fullscreen_exit_sharp':
        0xe9c6, // [sharp] navigation — adjust, arrows, cinema, close, collapse
    'fullscreen_outlined':
        0xf0b9, // [outline] navigation — adjust, aspect ratio, big, cinema mode, display
    'fullscreen_rounded':
        0xf7a6, // [round] navigation — adjust, aspect ratio, big, cinema mode, display
    'fullscreen_sharp':
        0xe9c7, // [sharp] navigation — adjust, aspect ratio, big, cinema mode, display
    'functions':
        0xe2cd, // editor — adjustments, administration, algorithms, automation, average
    'functions_outlined':
        0xf0ba, // [outline] editor — adjustments, administration, algorithms, automation, average
    'functions_rounded':
        0xf7a7, // [round] editor — adjustments, administration, algorithms, automation, average
    'functions_sharp':
        0xe9c8, // [sharp] editor — adjustments, administration, algorithms, automation, average
    'g_mobiledata':
        0xe2ce, // device — alphabet, bars, cell service, cellular, character
    'g_mobiledata_outlined':
        0xf0bb, // [outline] device — alphabet, bars, cell service, cellular, character
    'g_mobiledata_rounded':
        0xf7a8, // [round] device — alphabet, bars, cell service, cellular, character
    'g_mobiledata_sharp':
        0xe9c9, // [sharp] device — alphabet, bars, cell service, cellular, character
    'g_translate':
        0xe2cf, // action — alphabet, babel, communication, convert language, dictionary
    'g_translate_outlined':
        0xf0bc, // [outline] action — alphabet, babel, communication, convert language, dictionary
    'g_translate_rounded':
        0xf7a9, // [round] action — alphabet, babel, communication, convert language, dictionary
    'g_translate_sharp':
        0xe9ca, // [sharp] action — alphabet, babel, communication, convert language, dictionary
    'gamepad':
        0xe2d0, // hardware — accessory, activity, circles, console, controller
    'gamepad_outlined':
        0xf0bd, // [outline] hardware — accessory, activity, circles, console, controller
    'gamepad_rounded':
        0xf7aa, // [round] hardware — accessory, activity, circles, console, controller
    'gamepad_sharp':
        0xe9cb, // [sharp] hardware — accessory, activity, circles, console, controller
    'games': 0xe2d1, // av — accessory, activity, adjust, arrow, arrows
    'games_outlined':
        0xf0be, // [outline] av — accessory, activity, adjust, arrow, arrows
    'games_rounded':
        0xf7ab, // [round] av — accessory, activity, adjust, arrow, arrows
    'games_sharp':
        0xe9cc, // [sharp] av — accessory, activity, adjust, arrow, arrows
    'garage': 0xe2d2, // search — auto, automobile, automotive, building, car
    'garage_outlined':
        0xf0bf, // [outline] search — auto, automobile, automotive, building, car
    'garage_rounded':
        0xf7ac, // [round] search — auto, automobile, automotive, building, car
    'garage_sharp':
        0xe9cd, // [sharp] search — auto, automobile, automotive, building, car
    'gas_meter':
        0xf07a4, // home — analog indicator, analog meter, circular gauge, circular meter, consumption
    'gas_meter_outlined':
        0xf06f4, // [outline] home — analog indicator, analog meter, circular gauge, circular meter, consumption
    'gas_meter_rounded':
        0xf07fc, // [round] home — analog indicator, analog meter, circular gauge, circular meter, consumption
    'gas_meter_sharp':
        0xf074c, // [sharp] home — analog indicator, analog meter, circular gauge, circular meter, consumption
    'gavel':
        0xe2d3, // action — agreement, attorney, auction, authority, command
    'gavel_outlined':
        0xf0c0, // [outline] action — agreement, attorney, auction, authority, command
    'gavel_rounded':
        0xf7ad, // [round] action — agreement, attorney, auction, authority, command
    'gavel_sharp':
        0xe9ce, // [sharp] action — agreement, attorney, auction, authority, command
    'generating_tokens':
        0xf0511, // action — access, ai, algorithm, api, artificial
    'generating_tokens_outlined':
        0xf060a, // [outline] action — access, ai, algorithm, api, artificial
    'generating_tokens_rounded':
        0xf0329, // [round] action — access, ai, algorithm, api, artificial
    'generating_tokens_sharp':
        0xf041c, // [sharp] action — access, ai, algorithm, api, artificial
    'gesture': 0xe2d4, // content — activate, arrow, click, cursor, diagonal
    'gesture_outlined':
        0xf0c1, // [outline] content — activate, arrow, click, cursor, diagonal
    'gesture_rounded':
        0xf7ae, // [round] content — activate, arrow, click, cursor, diagonal
    'gesture_sharp':
        0xe9cf, // [sharp] content — activate, arrow, click, cursor, diagonal
    'get_app': 0xe2d5, // action — acquire, archive, arrow, arrows, bar
    'get_app_outlined':
        0xf0c2, // [outline] action — acquire, archive, arrow, arrows, bar
    'get_app_rounded':
        0xf7af, // [round] action — acquire, archive, arrow, arrows, bar
    'get_app_sharp':
        0xe9d0, // [sharp] action — acquire, archive, arrow, arrows, bar
    'gif':
        0xe2d6, // action — abbreviation, alphabet, animated, animation, bitmap
    'gif_box': 0xf0512, // action — add, alphabet, animated, animation, bitmap
    'gif_box_outlined':
        0xf060b, // [outline] action — add, alphabet, animated, animation, bitmap
    'gif_box_rounded':
        0xf032a, // [round] action — add, alphabet, animated, animation, bitmap
    'gif_box_sharp':
        0xf041d, // [sharp] action — add, alphabet, animated, animation, bitmap
    'gif_outlined':
        0xf0c3, // [outline] action — abbreviation, alphabet, animated, animation, bitmap
    'gif_rounded':
        0xf7b0, // [round] action — abbreviation, alphabet, animated, animation, bitmap
    'gif_sharp':
        0xe9d1, // [sharp] action — abbreviation, alphabet, animated, animation, bitmap
    'girl': 0xf0513, // social — account, avatar, body, character, female
    'girl_outlined':
        0xf060c, // [outline] social — account, avatar, body, character, female
    'girl_rounded':
        0xf032b, // [round] social — account, avatar, body, character, female
    'girl_sharp':
        0xf041e, // [sharp] social — account, avatar, body, character, female
    'gite': 0xe2d7, // places — architecture, automation, branch, changes, code
    'gite_outlined':
        0xf0c4, // [outline] places — architecture, automation, branch, changes, code
    'gite_rounded':
        0xf7b1, // [round] places — architecture, automation, branch, changes, code
    'gite_sharp':
        0xe9d2, // [sharp] places — architecture, automation, branch, changes, code
    'golf_course': 0xe2d8, // places — activity, area, athlete, athletic, ball
    'golf_course_outlined':
        0xf0c5, // [outline] places — activity, area, athlete, athletic, ball
    'golf_course_rounded':
        0xf7b2, // [round] places — activity, area, athlete, athletic, ball
    'golf_course_sharp':
        0xe9d3, // [sharp] places — activity, area, athlete, athletic, ball
    'gpp_bad': 0xe2d9, // device — access denied, alert, bad, blocked, cancel
    'gpp_bad_outlined':
        0xf0c6, // [outline] device — access denied, alert, bad, blocked, cancel
    'gpp_bad_rounded':
        0xf7b3, // [round] device — access denied, alert, bad, blocked, cancel
    'gpp_bad_sharp':
        0xe9d4, // [sharp] device — access denied, alert, bad, blocked, cancel
    'gpp_good':
        0xe2da, // device — badge, certified, check, complete, confirmation
    'gpp_good_outlined':
        0xf0c7, // [outline] device — badge, certified, check, complete, confirmation
    'gpp_good_rounded':
        0xf7b4, // [round] device — badge, certified, check, complete, confirmation
    'gpp_good_sharp':
        0xe9d5, // [sharp] device — badge, certified, check, complete, confirmation
    'gpp_maybe':
        0xe2db, // device — !, alert, attention, authenticate, authentication
    'gpp_maybe_outlined':
        0xf0c8, // [outline] device — !, alert, attention, authenticate, authentication
    'gpp_maybe_rounded':
        0xf7b5, // [round] device — !, alert, attention, authenticate, authentication
    'gpp_maybe_sharp':
        0xe9d6, // [sharp] device — !, alert, attention, authenticate, authentication
    'gps_fixed':
        0xe2dc, // device — area, center location, circle, compass, coordinates
    'gps_fixed_outlined':
        0xf0c9, // [outline] device — area, center location, circle, compass, coordinates
    'gps_fixed_rounded':
        0xf7b6, // [round] device — area, center location, circle, compass, coordinates
    'gps_fixed_sharp':
        0xe9d7, // [sharp] device — area, center location, circle, compass, coordinates
    'gps_not_fixed':
        0xe2dd, // device — acquire, acquiring, coordinates, current location, destination
    'gps_not_fixed_outlined':
        0xf0ca, // [outline] device — acquire, acquiring, coordinates, current location, destination
    'gps_not_fixed_rounded':
        0xf7b7, // [round] device — acquire, acquiring, coordinates, current location, destination
    'gps_not_fixed_sharp':
        0xe9d8, // [sharp] device — acquire, acquiring, coordinates, current location, destination
    'gps_off': 0xe2de, // device — access denied, alert, blocked, circle, cross
    'gps_off_outlined':
        0xf0cb, // [outline] device — access denied, alert, blocked, circle, cross
    'gps_off_rounded':
        0xf7b8, // [round] device — access denied, alert, blocked, circle, cross
    'gps_off_sharp':
        0xe9d9, // [sharp] device — access denied, alert, blocked, circle, cross
    'grade':
        0xe2df, // action — add to favorite, bookmark, empty, empty star, favorite
    'grade_outlined':
        0xf0cc, // [outline] action — add to favorite, bookmark, empty, empty star, favorite
    'grade_rounded':
        0xf7b9, // [round] action — add to favorite, bookmark, empty, empty star, favorite
    'grade_sharp':
        0xe9da, // [sharp] action — add to favorite, bookmark, empty, empty star, favorite
    'gradient': 0xe2e0, // image — appearance, art, background, blend, color
    'gradient_outlined':
        0xf0cd, // [outline] image — appearance, art, background, blend, color
    'gradient_rounded':
        0xf7ba, // [round] image — appearance, art, background, blend, color
    'gradient_sharp':
        0xe9db, // [sharp] image — appearance, art, background, blend, color
    'grading': 0xe2e1, // action — approved, assess, check, checklist, complete
    'grading_outlined':
        0xf0ce, // [outline] action — approved, assess, check, checklist, complete
    'grading_rounded':
        0xf7bb, // [round] action — approved, assess, check, checklist, complete
    'grading_sharp':
        0xe9dc, // [sharp] action — approved, assess, check, checklist, complete
    'grain': 0xe2e2, // image — adjust, analog, art, detail, digital art
    'grain_outlined':
        0xf0cf, // [outline] image — adjust, analog, art, detail, digital art
    'grain_rounded':
        0xf7bc, // [round] image — adjust, analog, art, detail, digital art
    'grain_sharp':
        0xe9dd, // [sharp] image — adjust, analog, art, detail, digital art
    'graphic_eq':
        0xe2e3, // device — audio, audio analysis, audio control, audio customization, audio effect
    'graphic_eq_outlined':
        0xf0d0, // [outline] device — audio, audio analysis, audio control, audio customization, audio effect
    'graphic_eq_rounded':
        0xf7bd, // [round] device — audio, audio analysis, audio control, audio customization, audio effect
    'graphic_eq_sharp':
        0xe9de, // [sharp] device — audio, audio analysis, audio control, audio customization, audio effect
    'grass':
        0xe2e4, // places — agriculture, backyard, blade, botanical, cultivate
    'grass_outlined':
        0xf0d1, // [outline] places — agriculture, backyard, blade, botanical, cultivate
    'grass_rounded':
        0xf7be, // [round] places — agriculture, backyard, blade, botanical, cultivate
    'grass_sharp':
        0xe9df, // [sharp] places — agriculture, backyard, blade, botanical, cultivate
    'grid_3x3': 0xe2e5, // device — 3, 3x3 grid, album view, area, arrange
    'grid_3x3_outlined':
        0xf0d2, // [outline] device — 3, 3x3 grid, album view, area, arrange
    'grid_3x3_rounded':
        0xf7bf, // [round] device — 3, 3x3 grid, album view, area, arrange
    'grid_3x3_sharp':
        0xe9e0, // [sharp] device — 3, 3x3 grid, album view, area, arrange
    'grid_4x4': 0xe2e6, // device — 4, 4x4, arrangement, block, by
    'grid_4x4_outlined':
        0xf0d3, // [outline] device — 4, 4x4, arrangement, block, by
    'grid_4x4_rounded':
        0xf7c0, // [round] device — 4, 4x4, arrangement, block, by
    'grid_4x4_sharp': 0xe9e1, // [sharp] device — 4, 4x4, arrangement, block, by
    'grid_goldenratio':
        0xe2e7, // device — aesthetic, alignment, arrangement, art, balance
    'grid_goldenratio_outlined':
        0xf0d4, // [outline] device — aesthetic, alignment, arrangement, art, balance
    'grid_goldenratio_rounded':
        0xf7c1, // [round] device — aesthetic, alignment, arrangement, art, balance
    'grid_goldenratio_sharp':
        0xe9e2, // [sharp] device — aesthetic, alignment, arrangement, art, balance
    'grid_off':
        0xe2e8, // image — arrangement, blocked, collage, cross out, diagonal line
    'grid_off_outlined':
        0xf0d5, // [outline] image — arrangement, blocked, collage, cross out, diagonal line
    'grid_off_rounded':
        0xf7c2, // [round] image — arrangement, blocked, collage, cross out, diagonal line
    'grid_off_sharp':
        0xe9e3, // [sharp] image — arrangement, blocked, collage, cross out, diagonal line
    'grid_on': 0xe2e9, // image — alignment, arrange, array, background, blocks
    'grid_on_outlined':
        0xf0d6, // [outline] image — alignment, arrange, array, background, blocks
    'grid_on_rounded':
        0xf7c3, // [round] image — alignment, arrange, array, background, blocks
    'grid_on_sharp':
        0xe9e4, // [sharp] image — alignment, arrange, array, background, blocks
    'grid_view':
        0xe2ea, // file — application square, arrangement, block layout, blocks, boxes
    'grid_view_outlined':
        0xf0d7, // [outline] file — application square, arrangement, block layout, blocks, boxes
    'grid_view_rounded':
        0xf7c4, // [round] file — application square, arrangement, block layout, blocks, boxes
    'grid_view_sharp':
        0xe9e5, // [sharp] file — application square, arrangement, block layout, blocks, boxes
    'group':
        0xe2eb, // social — accounts, administration, audience, committee, community
    'group_add':
        0xe2ec, // social — accounts, add, add friend, add member, add user
    'group_add_outlined':
        0xf0d8, // [outline] social — accounts, add, add friend, add member, add user
    'group_add_rounded':
        0xf7c5, // [round] social — accounts, add, add friend, add member, add user
    'group_add_sharp':
        0xe9e6, // [sharp] social — accounts, add, add friend, add member, add user
    'group_off':
        0xf0514, // social — association off, body, cancel group, club, cluster off
    'group_off_outlined':
        0xf060d, // [outline] social — association off, body, cancel group, club, cluster off
    'group_off_rounded':
        0xf032c, // [round] social — association off, body, cancel group, club, cluster off
    'group_off_sharp':
        0xf041f, // [sharp] social — association off, body, cancel group, club, cluster off
    'group_outlined':
        0xf0d9, // [outline] social — accounts, administration, audience, committee, community
    'group_remove':
        0xf0515, // social — account remove, accounts, collaboration, committee, community
    'group_remove_outlined':
        0xf060e, // [outline] social — account remove, accounts, collaboration, committee, community
    'group_remove_rounded':
        0xf032d, // [round] social — account remove, accounts, collaboration, committee, community
    'group_remove_sharp':
        0xf0420, // [sharp] social — account remove, accounts, collaboration, committee, community
    'group_rounded':
        0xf7c6, // [round] social — accounts, administration, audience, committee, community
    'group_sharp':
        0xe9e7, // [sharp] social — accounts, administration, audience, committee, community
    'group_work':
        0xe2ed, // action — alliance, assembly, association, avatars, business
    'group_work_outlined':
        0xf0da, // [outline] action — alliance, assembly, association, avatars, business
    'group_work_rounded':
        0xf7c7, // [round] action — alliance, assembly, association, avatars, business
    'group_work_sharp':
        0xe9e8, // [sharp] action — alliance, assembly, association, avatars, business
    'groups': 0xe2ee, // social — audience, avatars, body, club, collaboration
    'groups_2': 0xf0869, // social — assembly, avatars, body, circle, club
    'groups_2_outlined':
        0xf08a8, // [outline] social — assembly, avatars, body, circle, club
    'groups_2_rounded':
        0xf088a, // [round] social — assembly, avatars, body, circle, club
    'groups_2_sharp':
        0xf0841, // [sharp] social — assembly, avatars, body, circle, club
    'groups_3':
        0xf086a, // social — abstract, account, assembly, audience, avatars
    'groups_3_outlined':
        0xf08a9, // [outline] social — abstract, account, assembly, audience, avatars
    'groups_3_rounded':
        0xf088b, // [round] social — abstract, account, assembly, audience, avatars
    'groups_3_sharp':
        0xf0842, // [sharp] social — abstract, account, assembly, audience, avatars
    'groups_outlined':
        0xf0db, // [outline] social — audience, avatars, body, club, collaboration
    'groups_rounded':
        0xf7c8, // [round] social — audience, avatars, body, club, collaboration
    'groups_sharp':
        0xe9e9, // [sharp] social — audience, avatars, body, club, collaboration
    'h_mobiledata':
        0xe2ef, // device — 4g, alphabet, alphanumeric, cellular, cellular connection
    'h_mobiledata_outlined':
        0xf0dc, // [outline] device — 4g, alphabet, alphanumeric, cellular, cellular connection
    'h_mobiledata_rounded':
        0xf7c9, // [round] device — 4g, alphabet, alphanumeric, cellular, cellular connection
    'h_mobiledata_sharp':
        0xe9ea, // [sharp] device — 4g, alphabet, alphanumeric, cellular, cellular connection
    'h_plus_mobiledata': 0xe2f0, // device — +, 3g, 4g, access, alphabet
    'h_plus_mobiledata_outlined':
        0xf0dd, // [outline] device — +, 3g, 4g, access, alphabet
    'h_plus_mobiledata_rounded':
        0xf7ca, // [round] device — +, 3g, 4g, access, alphabet
    'h_plus_mobiledata_sharp':
        0xe9eb, // [sharp] device — +, 3g, 4g, access, alphabet
    'hail': 0xe2f1, // maps — alert, bad weather, body, circles, climate
    'hail_outlined':
        0xf0de, // [outline] maps — alert, bad weather, body, circles, climate
    'hail_rounded':
        0xf7cb, // [round] maps — alert, bad weather, body, circles, climate
    'hail_sharp':
        0xe9ec, // [sharp] maps — alert, bad weather, body, circles, climate
    'handshake':
        0xf06be, // social — accord, agreement, alliance, business, collaboration
    'handshake_outlined':
        0xf06a4, // [outline] social — accord, agreement, alliance, business, collaboration
    'handshake_rounded':
        0xf06cb, // [round] social — accord, agreement, alliance, business, collaboration
    'handshake_sharp':
        0xf06b1, // [sharp] social — accord, agreement, alliance, business, collaboration
    'handyman': 0xe2f2, // maps — adjust, build, builder, cog, configuration
    'handyman_outlined':
        0xf0df, // [outline] maps — adjust, build, builder, cog, configuration
    'handyman_rounded':
        0xf7cc, // [round] maps — adjust, build, builder, cog, configuration
    'handyman_sharp':
        0xe9ed, // [sharp] maps — adjust, build, builder, cog, configuration
    'hardware': 0xe2f3, // maps — adjust, administration, break, circle, cog
    'hardware_outlined':
        0xf0e0, // [outline] maps — adjust, administration, break, circle, cog
    'hardware_rounded':
        0xf7cd, // [round] maps — adjust, administration, break, circle, cog
    'hardware_sharp':
        0xe9ee, // [sharp] maps — adjust, administration, break, circle, cog
    'hd': 0xe2f4, // av — alphabet, character, clarity, codec, content
    'hd_outlined':
        0xf0e1, // [outline] av — alphabet, character, clarity, codec, content
    'hd_rounded':
        0xf7ce, // [round] av — alphabet, character, clarity, codec, content
    'hd_sharp':
        0xe9ef, // [sharp] av — alphabet, character, clarity, codec, content
    'hdr_auto': 0xe2f5, // device — A, adjustment, alphabet, auto, automatic
    'hdr_auto_outlined':
        0xf0e2, // [outline] device — A, adjustment, alphabet, auto, automatic
    'hdr_auto_rounded':
        0xf7cf, // [round] device — A, adjustment, alphabet, auto, automatic
    'hdr_auto_select': 0xe2f6, // device — +, A, adjustment, alphabet, auto
    'hdr_auto_select_outlined':
        0xf0e3, // [outline] device — +, A, adjustment, alphabet, auto
    'hdr_auto_select_rounded':
        0xf7d0, // [round] device — +, A, adjustment, alphabet, auto
    'hdr_auto_select_sharp':
        0xe9f0, // [sharp] device — +, A, adjustment, alphabet, auto
    'hdr_auto_sharp':
        0xe9f1, // [sharp] device — A, adjustment, alphabet, auto, automatic
    'hdr_enhanced_select':
        0xe2f7, // image — add, adjustment, alphabet, brightness, camera
    'hdr_enhanced_select_outlined':
        0xf0e4, // [outline] image — add, adjustment, alphabet, brightness, camera
    'hdr_enhanced_select_rounded':
        0xf7d1, // [round] image — add, adjustment, alphabet, brightness, camera
    'hdr_enhanced_select_sharp':
        0xe9f2, // [sharp] image — add, adjustment, alphabet, brightness, camera
    'hdr_off':
        0xe2f8, // image — alphabet, camera settings, cancel, character, diagonal line
    'hdr_off_outlined':
        0xf0e5, // [outline] image — alphabet, camera settings, cancel, character, diagonal line
    'hdr_off_rounded':
        0xf7d2, // [round] image — alphabet, camera settings, cancel, character, diagonal line
    'hdr_off_select':
        0xe2f9, // device — alphabet, camera, cancel, character, circle
    'hdr_off_select_outlined':
        0xf0e6, // [outline] device — alphabet, camera, cancel, character, circle
    'hdr_off_select_rounded':
        0xf7d3, // [round] device — alphabet, camera, cancel, character, circle
    'hdr_off_select_sharp':
        0xe9f3, // [sharp] device — alphabet, camera, cancel, character, circle
    'hdr_off_sharp':
        0xe9f4, // [sharp] image — alphabet, camera settings, cancel, character, diagonal line
    'hdr_on': 0xe2fa, // image — activate, add, alphabet, camera, capture
    'hdr_on_outlined':
        0xf0e7, // [outline] image — activate, add, alphabet, camera, capture
    'hdr_on_rounded':
        0xf7d4, // [round] image — activate, add, alphabet, camera, capture
    'hdr_on_select': 0xe2fb, // device — +, alphabet, bright, camera, character
    'hdr_on_select_outlined':
        0xf0e8, // [outline] device — +, alphabet, bright, camera, character
    'hdr_on_select_rounded':
        0xf7d5, // [round] device — +, alphabet, bright, camera, character
    'hdr_on_select_sharp':
        0xe9f5, // [sharp] device — +, alphabet, bright, camera, character
    'hdr_on_sharp':
        0xe9f6, // [sharp] image — activate, add, alphabet, camera, capture
    'hdr_plus': 0xe2fc, // image — +, activate, add, alphabet, camera
    'hdr_plus_outlined':
        0xf0e9, // [outline] image — +, activate, add, alphabet, camera
    'hdr_plus_rounded':
        0xf7d6, // [round] image — +, activate, add, alphabet, camera
    'hdr_plus_sharp':
        0xe9f7, // [sharp] image — +, activate, add, alphabet, camera
    'hdr_strong':
        0xe2fd, // image — adjust, adjust image, brightness, camera, camera settings
    'hdr_strong_outlined':
        0xf0ea, // [outline] image — adjust, adjust image, brightness, camera, camera settings
    'hdr_strong_rounded':
        0xf7d7, // [round] image — adjust, adjust image, brightness, camera, camera settings
    'hdr_strong_sharp':
        0xe9f8, // [sharp] image — adjust, adjust image, brightness, camera, camera settings
    'hdr_weak': 0xe2fe, // image — camera, circle, circles, contrast, correction
    'hdr_weak_outlined':
        0xf0eb, // [outline] image — camera, circle, circles, contrast, correction
    'hdr_weak_rounded':
        0xf7d8, // [round] image — camera, circle, circles, contrast, correction
    'hdr_weak_sharp':
        0xe9f9, // [sharp] image — camera, circle, circles, contrast, correction
    'headphones':
        0xe2ff, // hardware — accessory, audio, audio device, audio equipment, call
    'headphones_battery':
        0xe300, // hardware — accessory, audio, battery, bluetooth, charge
    'headphones_battery_outlined':
        0xf0ec, // [outline] hardware — accessory, audio, battery, bluetooth, charge
    'headphones_battery_rounded':
        0xf7d9, // [round] hardware — accessory, audio, battery, bluetooth, charge
    'headphones_battery_sharp':
        0xe9fa, // [sharp] hardware — accessory, audio, battery, bluetooth, charge
    'headphones_outlined':
        0xf0ed, // [outline] hardware — accessory, audio, audio device, audio equipment, call
    'headphones_rounded':
        0xf7da, // [round] hardware — accessory, audio, audio device, audio equipment, call
    'headphones_sharp':
        0xe9fb, // [sharp] hardware — accessory, audio, audio device, audio equipment, call
    'headset':
        0xe301, // hardware — accessory, audio, audio device, audio equipment, call
    'headset_mic':
        0xe302, // hardware — accessory, audio, audio device, band, boom mic
    'headset_mic_outlined':
        0xf0ee, // [outline] hardware — accessory, audio, audio device, band, boom mic
    'headset_mic_rounded':
        0xf7db, // [round] hardware — accessory, audio, audio device, band, boom mic
    'headset_mic_sharp':
        0xe9fc, // [sharp] hardware — accessory, audio, audio device, band, boom mic
    'headset_off':
        0xe303, // hardware — accessory, audio, audio off, broken, call
    'headset_off_outlined':
        0xf0ef, // [outline] hardware — accessory, audio, audio off, broken, call
    'headset_off_rounded':
        0xf7dc, // [round] hardware — accessory, audio, audio off, broken, call
    'headset_off_sharp':
        0xe9fd, // [sharp] hardware — accessory, audio, audio off, broken, call
    'headset_outlined':
        0xf0f0, // [outline] hardware — accessory, audio, audio device, audio equipment, call
    'headset_rounded':
        0xf7dd, // [round] hardware — accessory, audio, audio device, audio equipment, call
    'headset_sharp':
        0xe9fe, // [sharp] hardware — accessory, audio, audio device, audio equipment, call
    'healing': 0xe304, // image — aid, band-aid, bandage, clinic, cross
    'healing_outlined':
        0xf0f1, // [outline] image — aid, band-aid, bandage, clinic, cross
    'healing_rounded':
        0xf7de, // [round] image — aid, band-aid, bandage, clinic, cross
    'healing_sharp':
        0xe9ff, // [sharp] image — aid, band-aid, bandage, clinic, cross
    'health_and_safety': 0xe305, // social — +, add, aid, and, care
    'health_and_safety_outlined':
        0xf0f2, // [outline] social — +, add, aid, and, care
    'health_and_safety_rounded':
        0xf7df, // [round] social — +, add, aid, and, care
    'health_and_safety_sharp':
        0xea00, // [sharp] social — +, add, aid, and, care
    'hearing':
        0xe306, // av — abstract, accessibility, accessible, acoustic, aids
    'hearing_disabled':
        0xe307, // av — access, accessibility, accessible, aid, assist
    'hearing_disabled_outlined':
        0xf0f3, // [outline] av — access, accessibility, accessible, aid, assist
    'hearing_disabled_rounded':
        0xf7e0, // [round] av — access, accessibility, accessible, aid, assist
    'hearing_disabled_sharp':
        0xea01, // [sharp] av — access, accessibility, accessible, aid, assist
    'hearing_outlined':
        0xf0f4, // [outline] av — abstract, accessibility, accessible, acoustic, aids
    'hearing_rounded':
        0xf7e1, // [round] av — abstract, accessibility, accessible, acoustic, aids
    'hearing_sharp':
        0xea02, // [sharp] av — abstract, accessibility, accessible, acoustic, aids
    'heart_broken':
        0xf0516, // social — bad review, break, broken, broken heart, core
    'heart_broken_outlined':
        0xf060f, // [outline] social — bad review, break, broken, broken heart, core
    'heart_broken_rounded':
        0xf032e, // [round] social — bad review, break, broken, broken heart, core
    'heart_broken_sharp':
        0xf0421, // [sharp] social — bad review, break, broken, broken heart, core
    'heat_pump':
        0xf07a5, // home — air conditioner, air conditioning, air flow, appliance, building
    'heat_pump_outlined':
        0xf06f5, // [outline] home — air conditioner, air conditioning, air flow, appliance, building
    'heat_pump_rounded':
        0xf07fd, // [round] home — air conditioner, air conditioning, air flow, appliance, building
    'heat_pump_sharp':
        0xf074d, // [sharp] home — air conditioner, air conditioning, air flow, appliance, building
    'height':
        0xe308, // editor — arrow, calibration, color, dimension, dimension tool
    'height_outlined':
        0xf0f5, // [outline] editor — arrow, calibration, color, dimension, dimension tool
    'height_rounded':
        0xf7e2, // [round] editor — arrow, calibration, color, dimension, dimension tool
    'height_sharp':
        0xea03, // [sharp] editor — arrow, calibration, color, dimension, dimension tool
    'help': 0xe309, // action — ?, about, answer, assistance, circle
    'help_center': 0xe30a, // action — ?, advice, aid, ask, assistance
    'help_center_outlined':
        0xf0f6, // [outline] action — ?, advice, aid, ask, assistance
    'help_center_rounded':
        0xf7e3, // [round] action — ?, advice, aid, ask, assistance
    'help_center_sharp':
        0xea04, // [sharp] action — ?, advice, aid, ask, assistance
    'help_outline': 0xe30b, // action — ?, about, answer, assistance, circle
    'help_outline_outlined':
        0xf0f7, // [outline] action — ?, about, answer, assistance, circle
    'help_outline_rounded':
        0xf7e4, // [round] action — ?, about, answer, assistance, circle
    'help_outline_sharp':
        0xea05, // [sharp] action — ?, about, answer, assistance, circle
    'help_outlined':
        0xf0f8, // [outline] action — ?, about, answer, assistance, circle
    'help_rounded':
        0xf7e5, // [round] action — ?, about, answer, assistance, circle
    'help_sharp':
        0xea06, // [sharp] action — ?, about, answer, assistance, circle
    'hevc': 0xe30c, // image — abbreviation, acronym, alphabet, character, codec
    'hevc_outlined':
        0xf0f9, // [outline] image — abbreviation, acronym, alphabet, character, codec
    'hevc_rounded':
        0xf7e6, // [round] image — abbreviation, acronym, alphabet, character, codec
    'hevc_sharp':
        0xea07, // [sharp] image — abbreviation, acronym, alphabet, character, codec
    'hexagon':
        0xf0517, // editor — adjust, configuration, defense, futuristic, gears
    'hexagon_outlined':
        0xf0610, // [outline] editor — adjust, configuration, defense, futuristic, gears
    'hexagon_rounded':
        0xf032f, // [round] editor — adjust, configuration, defense, futuristic, gears
    'hexagon_sharp':
        0xf0422, // [sharp] editor — adjust, configuration, defense, futuristic, gears
    'hide_image': 0xe30d, // image — absence, artwork, blocked, broken, conceal
    'hide_image_outlined':
        0xf0fa, // [outline] image — absence, artwork, blocked, broken, conceal
    'hide_image_rounded':
        0xf7e7, // [round] image — absence, artwork, blocked, broken, conceal
    'hide_image_sharp':
        0xea08, // [sharp] image — absence, artwork, blocked, broken, conceal
    'hide_source':
        0xe30e, // action — access, circle, concealment, confidential, disabled
    'hide_source_outlined':
        0xf0fb, // [outline] action — access, circle, concealment, confidential, disabled
    'hide_source_rounded':
        0xf7e8, // [round] action — access, circle, concealment, confidential, disabled
    'hide_source_sharp':
        0xea09, // [sharp] action — access, circle, concealment, confidential, disabled
    'high_quality': 0xe30f, // av — achievement, alphabet, award, badge, best
    'high_quality_outlined':
        0xf0fc, // [outline] av — achievement, alphabet, award, badge, best
    'high_quality_rounded':
        0xf7e9, // [round] av — achievement, alphabet, award, badge, best
    'high_quality_sharp':
        0xea0a, // [sharp] av — achievement, alphabet, award, badge, best
    'highlight':
        0xe310, // editor — accent, annotate, annotation, attention, color
    'highlight_alt':
        0xe311, // action — alt, angle, area selection, arrow, bounding box
    'highlight_alt_outlined':
        0xf0fd, // [outline] action — alt, angle, area selection, arrow, bounding box
    'highlight_alt_rounded':
        0xf7ea, // [round] action — alt, angle, area selection, arrow, bounding box
    'highlight_alt_sharp':
        0xea0b, // [sharp] action — alt, angle, area selection, arrow, bounding box
    'highlight_off': 0xe312, // action — abort, block, cancel, circle, clear
    'highlight_off_outlined':
        0xf0fe, // [outline] action — abort, block, cancel, circle, clear
    'highlight_off_rounded':
        0xf7eb, // [round] action — abort, block, cancel, circle, clear
    'highlight_off_sharp':
        0xea0c, // [sharp] action — abort, block, cancel, circle, clear
    'highlight_outlined':
        0xf0ff, // [outline] editor — accent, annotate, annotation, attention, color
    'highlight_remove': 0xe312, // action — abort, block, cancel, circle, clear
    'highlight_remove_outlined':
        0xf0fe, // [outline] action — abort, block, cancel, circle, clear
    'highlight_remove_rounded':
        0xf7eb, // [round] action — abort, block, cancel, circle, clear
    'highlight_remove_sharp':
        0xea0c, // [sharp] action — abort, block, cancel, circle, clear
    'highlight_rounded':
        0xf7ec, // [round] editor — accent, annotate, annotation, attention, color
    'highlight_sharp':
        0xea0d, // [sharp] editor — accent, annotate, annotation, attention, color
    'hiking':
        0xe313, // social — activity, adventure, backpacking, bag, climbing
    'hiking_outlined':
        0xf100, // [outline] social — activity, adventure, backpacking, bag, climbing
    'hiking_rounded':
        0xf7ed, // [round] social — activity, adventure, backpacking, bag, climbing
    'hiking_sharp':
        0xea0e, // [sharp] social — activity, adventure, backpacking, bag, climbing
    'history': 0xe314, // action — activity, arrow, back, backup, backwards
    'history_edu': 0xe315, // social — academic, archive, book, clock, college
    'history_edu_outlined':
        0xf101, // [outline] social — academic, archive, book, clock, college
    'history_edu_rounded':
        0xf7ee, // [round] social — academic, archive, book, clock, college
    'history_edu_sharp':
        0xea0f, // [sharp] social — academic, archive, book, clock, college
    'history_outlined':
        0xf102, // [outline] action — activity, arrow, back, backup, backwards
    'history_rounded':
        0xf7ef, // [round] action — activity, arrow, back, backup, backwards
    'history_sharp':
        0xea10, // [sharp] action — activity, arrow, back, backup, backwards
    'history_toggle_off':
        0xe316, // action — activity, clock, dash, dashed, date
    'history_toggle_off_outlined':
        0xf103, // [outline] action — activity, clock, dash, dashed, date
    'history_toggle_off_rounded':
        0xf7f0, // [round] action — activity, clock, dash, dashed, date
    'history_toggle_off_sharp':
        0xea11, // [sharp] action — activity, clock, dash, dashed, date
    'hive': 0xf0518, // social — abstract, apiary, bee, beehive, cluster
    'hive_outlined':
        0xf0611, // [outline] social — abstract, apiary, bee, beehive, cluster
    'hive_rounded':
        0xf0330, // [round] social — abstract, apiary, bee, beehive, cluster
    'hive_sharp':
        0xf0423, // [sharp] social — abstract, apiary, bee, beehive, cluster
    'hls':
        0xf0519, // action — alphabet, broadcast, broadcasting, character, communication
    'hls_off':
        0xf051a, // action — alphabet, character, connection, cross, develop
    'hls_off_outlined':
        0xf0612, // [outline] action — alphabet, character, connection, cross, develop
    'hls_off_rounded':
        0xf0331, // [round] action — alphabet, character, connection, cross, develop
    'hls_off_sharp':
        0xf0424, // [sharp] action — alphabet, character, connection, cross, develop
    'hls_outlined':
        0xf0613, // [outline] action — alphabet, broadcast, broadcasting, character, communication
    'hls_rounded':
        0xf0332, // [round] action — alphabet, broadcast, broadcasting, character, communication
    'hls_sharp':
        0xf0425, // [sharp] action — alphabet, broadcast, broadcasting, character, communication
    'holiday_village':
        0xe317, // places — accommodation, architecture, beach, buildings, camping
    'holiday_village_outlined':
        0xf104, // [outline] places — accommodation, architecture, beach, buildings, camping
    'holiday_village_rounded':
        0xf7f1, // [round] places — accommodation, architecture, beach, buildings, camping
    'holiday_village_sharp':
        0xea12, // [sharp] places — accommodation, architecture, beach, buildings, camping
    'home':
        0xe318, // action — abode, address, application--house, architecture, beginning
    'home_filled':
        0xe319, // action — abode, address, application--house, architecture, beginning
    'home_max':
        0xe31a, // hardware — address, architecture, area, building, device
    'home_max_outlined':
        0xf105, // [outline] hardware — address, architecture, area, building, device
    'home_max_rounded':
        0xf7f2, // [round] hardware — address, architecture, area, building, device
    'home_max_sharp':
        0xea13, // [sharp] hardware — address, architecture, area, building, device
    'home_mini':
        0xe31b, // hardware — Internet, address, architecture, building, compact
    'home_mini_outlined':
        0xf106, // [outline] hardware — Internet, address, architecture, building, compact
    'home_mini_rounded':
        0xf7f3, // [round] hardware — Internet, address, architecture, building, compact
    'home_mini_sharp':
        0xea14, // [sharp] hardware — Internet, address, architecture, building, compact
    'home_outlined':
        0xf107, // [outline] action — abode, address, application--house, architecture, beginning
    'home_repair_service':
        0xe31c, // maps — adjustable wrench, box, building, construction, equipment
    'home_repair_service_outlined':
        0xf108, // [outline] maps — adjustable wrench, box, building, construction, equipment
    'home_repair_service_rounded':
        0xf7f4, // [round] maps — adjustable wrench, box, building, construction, equipment
    'home_repair_service_sharp':
        0xea15, // [sharp] maps — adjustable wrench, box, building, construction, equipment
    'home_rounded':
        0xf7f5, // [round] action — abode, address, application--house, architecture, beginning
    'home_sharp':
        0xea16, // [sharp] action — abode, address, application--house, architecture, beginning
    'home_work':
        0xe31d, // navigation — address, architecture, building, business, commercial
    'home_work_outlined':
        0xf109, // [outline] navigation — address, architecture, building, business, commercial
    'home_work_rounded':
        0xf7f6, // [round] navigation — address, architecture, building, business, commercial
    'home_work_sharp':
        0xea17, // [sharp] navigation — address, architecture, building, business, commercial
    'horizontal_distribute':
        0xe31e, // editor — align, alignment, arrangement, arrows, bar
    'horizontal_distribute_outlined':
        0xf10a, // [outline] editor — align, alignment, arrangement, arrows, bar
    'horizontal_distribute_rounded':
        0xf7f7, // [round] editor — align, alignment, arrangement, arrows, bar
    'horizontal_distribute_sharp':
        0xea18, // [sharp] editor — align, alignment, arrangement, arrows, bar
    'horizontal_rule':
        0xe31f, // editor — boundary, content separator, divide, divider, gap
    'horizontal_rule_outlined':
        0xf10b, // [outline] editor — boundary, content separator, divide, divider, gap
    'horizontal_rule_rounded':
        0xf7f8, // [round] editor — boundary, content separator, divide, divider, gap
    'horizontal_rule_sharp':
        0xea19, // [sharp] editor — boundary, content separator, divide, divider, gap
    'horizontal_split':
        0xe320, // action — arrangement, bars, content organization, display, display options
    'horizontal_split_outlined':
        0xf10c, // [outline] action — arrangement, bars, content organization, display, display options
    'horizontal_split_rounded':
        0xf7f9, // [round] action — arrangement, bars, content organization, display, display options
    'horizontal_split_sharp':
        0xea1a, // [sharp] action — arrangement, bars, content organization, display, display options
    'hot_tub': 0xe321, // places — bath, bathing, bathroom, bathtub, bubbles
    'hot_tub_outlined':
        0xf10d, // [outline] places — bath, bathing, bathroom, bathtub, bubbles
    'hot_tub_rounded':
        0xf7fa, // [round] places — bath, bathing, bathroom, bathtub, bubbles
    'hot_tub_sharp':
        0xea1b, // [sharp] places — bath, bathing, bathroom, bathtub, bubbles
    'hotel': 0xe322, // maps — accommodation, apartment, bed, body, booking
    'hotel_class':
        0xf051b, // action — accommodation, achievement, bed, booking, bookmark
    'hotel_class_outlined':
        0xf0614, // [outline] action — accommodation, achievement, bed, booking, bookmark
    'hotel_class_rounded':
        0xf0333, // [round] action — accommodation, achievement, bed, booking, bookmark
    'hotel_class_sharp':
        0xf0426, // [sharp] action — accommodation, achievement, bed, booking, bookmark
    'hotel_outlined':
        0xf10e, // [outline] maps — accommodation, apartment, bed, body, booking
    'hotel_rounded':
        0xf7fb, // [round] maps — accommodation, apartment, bed, body, booking
    'hotel_sharp':
        0xea1c, // [sharp] maps — accommodation, apartment, bed, body, booking
    'hourglass_bottom':
        0xe323, // communication — bottom, clock, completed, completion, countdown
    'hourglass_bottom_outlined':
        0xf10f, // [outline] communication — bottom, clock, completed, completion, countdown
    'hourglass_bottom_rounded':
        0xf7fc, // [round] communication — bottom, clock, completed, completion, countdown
    'hourglass_bottom_sharp':
        0xea1d, // [sharp] communication — bottom, clock, completed, completion, countdown
    'hourglass_disabled':
        0xe324, // action — angled line, circle, clock, complete, countdown
    'hourglass_disabled_outlined':
        0xf110, // [outline] action — angled line, circle, clock, complete, countdown
    'hourglass_disabled_rounded':
        0xf7fd, // [round] action — angled line, circle, clock, complete, countdown
    'hourglass_disabled_sharp':
        0xea1e, // [sharp] action — angled line, circle, clock, complete, countdown
    'hourglass_empty':
        0xe325, // action — abstract, clock, countdown, delay, duration
    'hourglass_empty_outlined':
        0xf111, // [outline] action — abstract, clock, countdown, delay, duration
    'hourglass_empty_rounded':
        0xf7fe, // [round] action — abstract, clock, countdown, delay, duration
    'hourglass_empty_sharp':
        0xea1f, // [sharp] action — abstract, clock, countdown, delay, duration
    'hourglass_full':
        0xe326, // action — antique, classic, countdown, delay, duration
    'hourglass_full_outlined':
        0xf112, // [outline] action — antique, classic, countdown, delay, duration
    'hourglass_full_rounded':
        0xf7ff, // [round] action — antique, classic, countdown, delay, duration
    'hourglass_full_sharp':
        0xea20, // [sharp] action — antique, classic, countdown, delay, duration
    'hourglass_top':
        0xe327, // communication — antique, bulb, classic, countdown, delay
    'hourglass_top_outlined':
        0xf113, // [outline] communication — antique, bulb, classic, countdown, delay
    'hourglass_top_rounded':
        0xf800, // [round] communication — antique, bulb, classic, countdown, delay
    'hourglass_top_sharp':
        0xea21, // [sharp] communication — antique, bulb, classic, countdown, delay
    'house': 0xe328, // places — abode, architecture, building, door, dwelling
    'house_outlined':
        0xf114, // [outline] places — abode, architecture, building, door, dwelling
    'house_rounded':
        0xf801, // [round] places — abode, architecture, building, door, dwelling
    'house_sharp':
        0xea22, // [sharp] places — abode, architecture, building, door, dwelling
    'house_siding':
        0xe329, // places — aluminum, architectural, architecture, building, building material
    'house_siding_outlined':
        0xf115, // [outline] places — aluminum, architectural, architecture, building, building material
    'house_siding_rounded':
        0xf802, // [round] places — aluminum, architectural, architecture, building, building material
    'house_siding_sharp':
        0xea23, // [sharp] places — aluminum, architectural, architecture, building, building material
    'houseboat':
        0xe32a, // places — accommodation, aquatic, architecture, beach, boat
    'houseboat_outlined':
        0xf116, // [outline] places — accommodation, aquatic, architecture, beach, boat
    'houseboat_rounded':
        0xf803, // [round] places — accommodation, aquatic, architecture, beach, boat
    'houseboat_sharp':
        0xea24, // [sharp] places — accommodation, aquatic, architecture, beach, boat
    'how_to_reg':
        0xe32b, // content — accept, access, account, add user, approve
    'how_to_reg_outlined':
        0xf117, // [outline] content — accept, access, account, add user, approve
    'how_to_reg_rounded':
        0xf804, // [round] content — accept, access, account, add user, approve
    'how_to_reg_sharp':
        0xea25, // [sharp] content — accept, access, account, add user, approve
    'how_to_vote':
        0xe32c, // content — ballot, ballot box, ballot paper, casting a vote, check
    'how_to_vote_outlined':
        0xf118, // [outline] content — ballot, ballot box, ballot paper, casting a vote, check
    'how_to_vote_rounded':
        0xf805, // [round] content — ballot, ballot box, ballot paper, casting a vote, check
    'how_to_vote_sharp':
        0xea26, // [sharp] content — ballot, ballot box, ballot paper, casting a vote, check
    'html':
        0xf051c, // action — alphabet, angle brackets, brackets, character, code
    'html_outlined':
        0xf0615, // [outline] action — alphabet, angle brackets, brackets, character, code
    'html_rounded':
        0xf0334, // [round] action — alphabet, angle brackets, brackets, character, code
    'html_sharp':
        0xf0427, // [sharp] action — alphabet, angle brackets, brackets, character, code
    'http': 0xe32d, // action — access, address, address bar, alphabet, browser
    'http_outlined':
        0xf119, // [outline] action — access, address, address bar, alphabet, browser
    'http_rounded':
        0xf806, // [round] action — access, address, address bar, alphabet, browser
    'http_sharp':
        0xea27, // [sharp] action — access, address, address bar, alphabet, browser
    'https':
        0xe32e, // action — access, authentication, authorization, browser, closed
    'https_outlined':
        0xf11a, // [outline] action — access, authentication, authorization, browser, closed
    'https_rounded':
        0xf807, // [round] action — access, authentication, authorization, browser, closed
    'https_sharp':
        0xea28, // [sharp] action — access, authentication, authorization, browser, closed
    'hub':
        0xf051d, // communication — access, center, central, connect, connection
    'hub_outlined':
        0xf0616, // [outline] communication — access, center, central, connect, connection
    'hub_rounded':
        0xf0335, // [round] communication — access, center, central, connect, connection
    'hub_sharp':
        0xf0428, // [sharp] communication — access, center, central, connect, connection
    'hvac': 0xe32f, // maps — ac, adjustment, air, air conditioning, air flow
    'hvac_outlined':
        0xf11b, // [outline] maps — ac, adjustment, air, air conditioning, air flow
    'hvac_rounded':
        0xf808, // [round] maps — ac, adjustment, air, air conditioning, air flow
    'hvac_sharp':
        0xea29, // [sharp] maps — ac, adjustment, air, air conditioning, air flow
    'ice_skating': 0xe330, // social — activity, athlete, athletic, blade, boot
    'ice_skating_outlined':
        0xf11c, // [outline] social — activity, athlete, athletic, blade, boot
    'ice_skating_rounded':
        0xf809, // [round] social — activity, athlete, athletic, blade, boot
    'ice_skating_sharp':
        0xea2a, // [sharp] social — activity, athlete, athletic, blade, boot
    'icecream': 0xe331, // maps — cafe, celebration, circle, cold, cone
    'icecream_outlined':
        0xf11d, // [outline] maps — cafe, celebration, circle, cold, cone
    'icecream_rounded':
        0xf80a, // [round] maps — cafe, celebration, circle, cold, cone
    'icecream_sharp':
        0xea2b, // [sharp] maps — cafe, celebration, circle, cold, cone
    'image': 0xe332, // image — add, adjust, album, asset, camera
    'image_aspect_ratio':
        0xe333, // image — adjust, aspect, aspect ratio, crop, dimensions
    'image_aspect_ratio_outlined':
        0xf11e, // [outline] image — adjust, aspect, aspect ratio, crop, dimensions
    'image_aspect_ratio_rounded':
        0xf80b, // [round] image — adjust, aspect, aspect ratio, crop, dimensions
    'image_aspect_ratio_sharp':
        0xea2c, // [sharp] image — adjust, aspect, aspect ratio, crop, dimensions
    'image_not_supported':
        0xe334, // image — alert, broken, cancel, content, disabled
    'image_not_supported_outlined':
        0xf11f, // [outline] image — alert, broken, cancel, content, disabled
    'image_not_supported_rounded':
        0xf80c, // [round] image — alert, broken, cancel, content, disabled
    'image_not_supported_sharp':
        0xea2d, // [sharp] image — alert, broken, cancel, content, disabled
    'image_outlined':
        0xf120, // [outline] image — add, adjust, album, asset, camera
    'image_rounded':
        0xf80d, // [round] image — add, adjust, album, asset, camera
    'image_search':
        0xe335, // image — analyze, bing visual search, camera search, content search, database search
    'image_search_outlined':
        0xf121, // [outline] image — analyze, bing visual search, camera search, content search, database search
    'image_search_rounded':
        0xf80e, // [round] image — analyze, bing visual search, camera search, content search, database search
    'image_search_sharp':
        0xea2e, // [sharp] image — analyze, bing visual search, camera search, content search, database search
    'image_sharp': 0xea2f, // [sharp] image — add, adjust, album, asset, camera
    'imagesearch_roller':
        0xe336, // notification — appearance, applicator, apply, art, brush
    'imagesearch_roller_outlined':
        0xf122, // [outline] notification — appearance, applicator, apply, art, brush
    'imagesearch_roller_rounded':
        0xf80f, // [round] notification — appearance, applicator, apply, art, brush
    'imagesearch_roller_sharp':
        0xea30, // [sharp] notification — appearance, applicator, apply, art, brush
    'import_contacts':
        0xe337, // communication — address, address book, book, communicate, contacts
    'import_contacts_outlined':
        0xf123, // [outline] communication — address, address book, book, communicate, contacts
    'import_contacts_rounded':
        0xf810, // [round] communication — address, address book, book, communicate, contacts
    'import_contacts_sharp':
        0xea31, // [sharp] communication — address, address book, book, communicate, contacts
    'import_export':
        0xe338, // communication — arrow, arrows, bidirectional, connection, direction
    'import_export_outlined':
        0xf124, // [outline] communication — arrow, arrows, bidirectional, connection, direction
    'import_export_rounded':
        0xf811, // [round] communication — arrow, arrows, bidirectional, connection, direction
    'import_export_sharp':
        0xea32, // [sharp] communication — arrow, arrows, bidirectional, connection, direction
    'important_devices':
        0xe339, // action — Android, OS, access, communication, computer
    'important_devices_outlined':
        0xf125, // [outline] action — Android, OS, access, communication, computer
    'important_devices_rounded':
        0xf812, // [round] action — Android, OS, access, communication, computer
    'important_devices_sharp':
        0xea33, // [sharp] action — Android, OS, access, communication, computer
    'inbox': 0xe33a, // content — archive, arrival, box, category, communication
    'inbox_outlined':
        0xf126, // [outline] content — archive, arrival, box, category, communication
    'inbox_rounded':
        0xf813, // [round] content — archive, arrival, box, category, communication
    'inbox_sharp':
        0xea34, // [sharp] content — archive, arrival, box, category, communication
    'incomplete_circle':
        0xf051e, // image — active, activity indicator, animation, arc, broken circle
    'incomplete_circle_outlined':
        0xf0617, // [outline] image — active, activity indicator, animation, arc, broken circle
    'incomplete_circle_rounded':
        0xf0336, // [round] image — active, activity indicator, animation, arc, broken circle
    'incomplete_circle_sharp':
        0xf0429, // [sharp] image — active, activity indicator, animation, arc, broken circle
    'indeterminate_check_box':
        0xe33b, // toggle — box, box with line, check, checkbox, checkbox with line
    'indeterminate_check_box_outlined':
        0xf127, // [outline] toggle — box, box with line, check, checkbox, checkbox with line
    'indeterminate_check_box_rounded':
        0xf814, // [round] toggle — box, box with line, check, checkbox, checkbox with line
    'indeterminate_check_box_sharp':
        0xea35, // [sharp] toggle — box, box with line, check, checkbox, checkbox with line
    'info': 0xe33c, // action — about, alert, announcement, assistance, circle
    'info_outline':
        0xe33d, // action — alert, announcement, assistance, details, help
    'info_outline_rounded':
        0xf815, // [round] action — alert, announcement, assistance, details, help
    'info_outline_sharp':
        0xea36, // [sharp] action — alert, announcement, assistance, details, help
    'info_outlined':
        0xf128, // [outline] action — about, alert, announcement, assistance, circle
    'info_rounded':
        0xf816, // [round] action — about, alert, announcement, assistance, circle
    'info_sharp':
        0xea37, // [sharp] action — about, alert, announcement, assistance, circle
    'input': 0xe33e, // action — accept, apply, approve, arrow, box
    'input_outlined':
        0xf129, // [outline] action — accept, apply, approve, arrow, box
    'input_rounded':
        0xf817, // [round] action — accept, apply, approve, arrow, box
    'input_sharp':
        0xea38, // [sharp] action — accept, apply, approve, arrow, box
    'insert_chart':
        0xe33f, // editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_outlined':
        0xf12a, // [outline] editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_outlined_outlined':
        0xf12b, // [outline] editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_outlined_rounded':
        0xf818, // [round] editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_outlined_sharp':
        0xea39, // [sharp] editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_rounded':
        0xf819, // [round] editor — analysis, analytics, assessment, bar, bar chart
    'insert_chart_sharp':
        0xea3a, // [sharp] editor — analysis, analytics, assessment, bar, bar chart
    'insert_comment':
        0xe341, // editor — add, add comment, balloon, bubble, chat
    'insert_comment_outlined':
        0xf12c, // [outline] editor — add, add comment, balloon, bubble, chat
    'insert_comment_rounded':
        0xf81a, // [round] editor — add, add comment, balloon, bubble, chat
    'insert_comment_sharp':
        0xea3b, // [sharp] editor — add, add comment, balloon, bubble, chat
    'insert_drive_file':
        0xe342, // editor — attachment, blank, doc, document, dog-ear
    'insert_drive_file_outlined':
        0xf12d, // [outline] editor — attachment, blank, doc, document, dog-ear
    'insert_drive_file_rounded':
        0xf81b, // [round] editor — attachment, blank, doc, document, dog-ear
    'insert_drive_file_sharp':
        0xea3c, // [sharp] editor — attachment, blank, doc, document, dog-ear
    'insert_emoticon':
        0xe343, // editor — account, add, character, chat, cheerful
    'insert_emoticon_outlined':
        0xf12e, // [outline] editor — account, add, character, chat, cheerful
    'insert_emoticon_rounded':
        0xf81c, // [round] editor — account, add, character, chat, cheerful
    'insert_emoticon_sharp':
        0xea3d, // [sharp] editor — account, add, character, chat, cheerful
    'insert_invitation':
        0xe344, // editor — add, add event, add invitation, add to calendar, agenda
    'insert_invitation_outlined':
        0xf12f, // [outline] editor — add, add event, add invitation, add to calendar, agenda
    'insert_invitation_rounded':
        0xf81d, // [round] editor — add, add event, add invitation, add to calendar, agenda
    'insert_invitation_sharp':
        0xea3e, // [sharp] editor — add, add event, add invitation, add to calendar, agenda
    'insert_link': 0xe345, // editor — add, anchor, arrow, attach, attachment
    'insert_link_outlined':
        0xf130, // [outline] editor — add, anchor, arrow, attach, attachment
    'insert_link_rounded':
        0xf81e, // [round] editor — add, anchor, arrow, attach, attachment
    'insert_link_sharp':
        0xea3f, // [sharp] editor — add, anchor, arrow, attach, attachment
    'insert_page_break':
        0xf0520, // editor — break, content break, dash, dashed, dashed line
    'insert_page_break_outlined':
        0xf0618, // [outline] editor — break, content break, dash, dashed, dashed line
    'insert_page_break_rounded':
        0xf0337, // [round] editor — break, content break, dash, dashed, dashed line
    'insert_page_break_sharp':
        0xf042a, // [sharp] editor — break, content break, dash, dashed, dashed line
    'insert_photo': 0xe346, // editor — add, adjust, album, asset, camera
    'insert_photo_outlined':
        0xf131, // [outline] editor — add, adjust, album, asset, camera
    'insert_photo_rounded':
        0xf81f, // [round] editor — add, adjust, album, asset, camera
    'insert_photo_sharp':
        0xea40, // [sharp] editor — add, adjust, album, asset, camera
    'insights':
        0xe347, // content — ai, analysis, analytics, analytics report, artificial
    'insights_outlined':
        0xf132, // [outline] content — ai, analysis, analytics, analytics report, artificial
    'insights_rounded':
        0xf820, // [round] content — ai, analysis, analytics, analytics report, artificial
    'insights_sharp':
        0xea41, // [sharp] content — ai, analysis, analytics, analytics report, artificial
    'install_desktop': 0xf0521, // action — Android, OS, add, chrome, computer
    'install_desktop_outlined':
        0xf0619, // [outline] action — Android, OS, add, chrome, computer
    'install_desktop_rounded':
        0xf0338, // [round] action — Android, OS, add, chrome, computer
    'install_desktop_sharp':
        0xf042b, // [sharp] action — Android, OS, add, chrome, computer
    'install_mobile':
        0xf0522, // action — Android, OS, app install, app promo, arrow
    'install_mobile_outlined':
        0xf061a, // [outline] action — Android, OS, app install, app promo, arrow
    'install_mobile_rounded':
        0xf0339, // [round] action — Android, OS, app install, app promo, arrow
    'install_mobile_sharp':
        0xf042c, // [sharp] action — Android, OS, app install, app promo, arrow
    'integration_instructions':
        0xe348, // action — automation, brackets, build, clipboard, code
    'integration_instructions_outlined':
        0xf133, // [outline] action — automation, brackets, build, clipboard, code
    'integration_instructions_rounded':
        0xf821, // [round] action — automation, brackets, build, clipboard, code
    'integration_instructions_sharp':
        0xea42, // [sharp] action — automation, brackets, build, clipboard, code
    'interests':
        0xf0523, // social — best, bookmark, chosen, circle, distinction
    'interests_outlined':
        0xf061b, // [outline] social — best, bookmark, chosen, circle, distinction
    'interests_rounded':
        0xf033a, // [round] social — best, bookmark, chosen, circle, distinction
    'interests_sharp':
        0xf042d, // [sharp] social — best, bookmark, chosen, circle, distinction
    'interpreter_mode':
        0xf0524, // av — account, accounts, assistant, audio, bilingual
    'interpreter_mode_outlined':
        0xf061c, // [outline] av — account, accounts, assistant, audio, bilingual
    'interpreter_mode_rounded':
        0xf033b, // [round] av — account, accounts, assistant, audio, bilingual
    'interpreter_mode_sharp':
        0xf042e, // [sharp] av — account, accounts, assistant, audio, bilingual
    'inventory': 0xe349, // content — archive, box, boxes, chain, clipboard
    'inventory_2': 0xe34a, // content — archive, assets, box, boxes, container
    'inventory_2_outlined':
        0xf134, // [outline] content — archive, assets, box, boxes, container
    'inventory_2_rounded':
        0xf822, // [round] content — archive, assets, box, boxes, container
    'inventory_2_sharp':
        0xea43, // [sharp] content — archive, assets, box, boxes, container
    'inventory_outlined':
        0xf135, // [outline] content — archive, box, boxes, chain, clipboard
    'inventory_rounded':
        0xf823, // [round] content — archive, box, boxes, chain, clipboard
    'inventory_sharp':
        0xea44, // [sharp] content — archive, box, boxes, chain, clipboard
    'invert_colors':
        0xe34b, // action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_off':
        0xe34c, // communication — accessibility, accessibility settings, appearance, circle, color
    'invert_colors_off_outlined':
        0xf136, // [outline] communication — accessibility, accessibility settings, appearance, circle, color
    'invert_colors_off_rounded':
        0xf824, // [round] communication — accessibility, accessibility settings, appearance, circle, color
    'invert_colors_off_sharp':
        0xea45, // [sharp] communication — accessibility, accessibility settings, appearance, circle, color
    'invert_colors_on':
        0xe34b, // action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_on_outlined':
        0xf137, // [outline] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_on_rounded':
        0xf825, // [round] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_on_sharp':
        0xea46, // [sharp] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_outlined':
        0xf137, // [outline] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_rounded':
        0xf825, // [round] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'invert_colors_sharp':
        0xea46, // [sharp] action — accessibility, accessibility settings, adjust, adjust colors, appearance
    'ios_share': 0xe34d, // social — apple, arrow, box, communication, connect
    'ios_share_outlined':
        0xf138, // [outline] social — apple, arrow, box, communication, connect
    'ios_share_rounded':
        0xf826, // [round] social — apple, arrow, box, communication, connect
    'ios_share_sharp':
        0xea47, // [sharp] social — apple, arrow, box, communication, connect
    'iron':
        0xe34e, // places — appliance, cleaning, clothes, clothes iron, clothing
    'iron_outlined':
        0xf139, // [outline] places — appliance, cleaning, clothes, clothes iron, clothing
    'iron_rounded':
        0xf827, // [round] places — appliance, cleaning, clothes, clothes iron, clothing
    'iron_sharp':
        0xea48, // [sharp] places — appliance, cleaning, clothes, clothes iron, clothing
    'iso': 0xe34f, // image — add, adjustment, bar, brightness, camera
    'iso_outlined':
        0xf13a, // [outline] image — add, adjustment, bar, brightness, camera
    'iso_rounded':
        0xf828, // [round] image — add, adjustment, bar, brightness, camera
    'iso_sharp':
        0xea49, // [sharp] image — add, adjustment, bar, brightness, camera
    'javascript':
        0xf0525, // action — alphabet, back end, brackets, character, code
    'javascript_outlined':
        0xf061d, // [outline] action — alphabet, back end, brackets, character, code
    'javascript_rounded':
        0xf033c, // [round] action — alphabet, back end, brackets, character, code
    'javascript_sharp':
        0xf042f, // [sharp] action — alphabet, back end, brackets, character, code
    'join_full':
        0xf0526, // action — attend, broadcast, call, circle, collaboration
    'join_full_outlined':
        0xf061e, // [outline] action — attend, broadcast, call, circle, collaboration
    'join_full_rounded':
        0xf033d, // [round] action — attend, broadcast, call, circle, collaboration
    'join_full_sharp':
        0xf0430, // [sharp] action — attend, broadcast, call, circle, collaboration
    'join_inner':
        0xf0527, // action — circle, combine, combine data, command, connect
    'join_inner_outlined':
        0xf061f, // [outline] action — circle, combine, combine data, command, connect
    'join_inner_rounded':
        0xf033e, // [round] action — circle, combine, combine data, command, connect
    'join_inner_sharp':
        0xf0431, // [sharp] action — circle, combine, combine data, command, connect
    'join_left': 0xf0528, // action — access, arrow, branch, circle, combine
    'join_left_outlined':
        0xf0620, // [outline] action — access, arrow, branch, circle, combine
    'join_left_rounded':
        0xf033f, // [round] action — access, arrow, branch, circle, combine
    'join_left_sharp':
        0xf0432, // [sharp] action — access, arrow, branch, circle, combine
    'join_right':
        0xf0529, // action — align right, alignment, arrow, association, chain link
    'join_right_outlined':
        0xf0621, // [outline] action — align right, alignment, arrow, association, chain link
    'join_right_rounded':
        0xf0340, // [round] action — align right, alignment, arrow, association, chain link
    'join_right_sharp':
        0xf0433, // [sharp] action — align right, alignment, arrow, association, chain link
    'kayaking': 0xe350, // social — activity, adventure, athlete, athletic, boat
    'kayaking_outlined':
        0xf13b, // [outline] social — activity, adventure, athlete, athletic, boat
    'kayaking_rounded':
        0xf829, // [round] social — activity, adventure, athlete, athletic, boat
    'kayaking_sharp':
        0xea4a, // [sharp] social — activity, adventure, athlete, athletic, boat
    'kebab_dining':
        0xf052a, // maps — additional options, chef, choices, context menu, cooking
    'kebab_dining_outlined':
        0xf0622, // [outline] maps — additional options, chef, choices, context menu, cooking
    'kebab_dining_rounded':
        0xf0341, // [round] maps — additional options, chef, choices, context menu, cooking
    'kebab_dining_sharp':
        0xf0434, // [sharp] maps — additional options, chef, choices, context menu, cooking
    'key':
        0xf052b, // communication — access, access key, authentication, authorization, code
    'key_off':
        0xf052c, // communication — access, barred, blocked, circle, closed
    'key_off_outlined':
        0xf0623, // [outline] communication — access, barred, blocked, circle, closed
    'key_off_rounded':
        0xf0342, // [round] communication — access, barred, blocked, circle, closed
    'key_off_sharp':
        0xf0435, // [sharp] communication — access, barred, blocked, circle, closed
    'key_outlined':
        0xf0624, // [outline] communication — access, access key, authentication, authorization, code
    'key_rounded':
        0xf0343, // [round] communication — access, access key, authentication, authorization, code
    'key_sharp':
        0xf0436, // [sharp] communication — access, access key, authentication, authorization, code
    'keyboard':
        0xe351, // hardware — access, chat, code, communication, computer
    'keyboard_alt':
        0xe352, // hardware — alphanumeric, chat, compose, computer, data entry
    'keyboard_alt_outlined':
        0xf13c, // [outline] hardware — alphanumeric, chat, compose, computer, data entry
    'keyboard_alt_rounded':
        0xf82a, // [round] hardware — alphanumeric, chat, compose, computer, data entry
    'keyboard_alt_sharp':
        0xea4b, // [sharp] hardware — alphanumeric, chat, compose, computer, data entry
    'keyboard_arrow_down':
        0xe353, // hardware — access, arrow, arrows, bottom, caret
    'keyboard_arrow_down_outlined':
        0xf13d, // [outline] hardware — access, arrow, arrows, bottom, caret
    'keyboard_arrow_down_rounded':
        0xf82b, // [round] hardware — access, arrow, arrows, bottom, caret
    'keyboard_arrow_down_sharp':
        0xea4c, // [sharp] hardware — access, arrow, arrows, bottom, caret
    'keyboard_arrow_left':
        0xe354, // hardware — angle, arrow, arrows, back, chevron
    'keyboard_arrow_left_outlined':
        0xf13e, // [outline] hardware — angle, arrow, arrows, back, chevron
    'keyboard_arrow_left_rounded':
        0xf82c, // [round] hardware — angle, arrow, arrows, back, chevron
    'keyboard_arrow_left_sharp':
        0xea4d, // [sharp] hardware — angle, arrow, arrows, back, chevron
    'keyboard_arrow_right':
        0xe355, // hardware — advance, angle, arrow, arrows, caret
    'keyboard_arrow_right_outlined':
        0xf13f, // [outline] hardware — advance, angle, arrow, arrows, caret
    'keyboard_arrow_right_rounded':
        0xf82d, // [round] hardware — advance, angle, arrow, arrows, caret
    'keyboard_arrow_right_sharp':
        0xea4e, // [sharp] hardware — advance, angle, arrow, arrows, caret
    'keyboard_arrow_up':
        0xe356, // hardware — accordion, angle, arrow, arrows, ascend
    'keyboard_arrow_up_outlined':
        0xf140, // [outline] hardware — accordion, angle, arrow, arrows, ascend
    'keyboard_arrow_up_rounded':
        0xf82e, // [round] hardware — accordion, angle, arrow, arrows, ascend
    'keyboard_arrow_up_sharp':
        0xea4f, // [sharp] hardware — accordion, angle, arrow, arrows, ascend
    'keyboard_backspace':
        0xe357, // hardware — arrow, back, backspace, caret, clear
    'keyboard_backspace_outlined':
        0xf141, // [outline] hardware — arrow, back, backspace, caret, clear
    'keyboard_backspace_rounded':
        0xf82f, // [round] hardware — arrow, back, backspace, caret, clear
    'keyboard_backspace_sharp':
        0xea50, // [sharp] hardware — arrow, back, backspace, caret, clear
    'keyboard_capslock':
        0xe358, // hardware — arrow, capslock, computer, direction, function
    'keyboard_capslock_outlined':
        0xf142, // [outline] hardware — arrow, capslock, computer, direction, function
    'keyboard_capslock_rounded':
        0xf830, // [round] hardware — arrow, capslock, computer, direction, function
    'keyboard_capslock_sharp':
        0xea51, // [sharp] hardware — arrow, capslock, computer, direction, function
    'keyboard_command_key':
        0xf052d, // hardware — apple, command, command key, computer key, computing
    'keyboard_command_key_outlined':
        0xf0625, // [outline] hardware — apple, command, command key, computer key, computing
    'keyboard_command_key_rounded':
        0xf0344, // [round] hardware — apple, command, command key, computer key, computing
    'keyboard_command_key_sharp':
        0xf0437, // [sharp] hardware — apple, command, command key, computer key, computing
    'keyboard_control':
        0xe402, // navigation — 3, additional, bar menu, choices, content menu
    'keyboard_control_key':
        0xf052e, // hardware — arrow, code, command, computer, control key
    'keyboard_control_key_outlined':
        0xf0626, // [outline] hardware — arrow, code, command, computer, control key
    'keyboard_control_key_rounded':
        0xf0345, // [round] hardware — arrow, code, command, computer, control key
    'keyboard_control_key_sharp':
        0xf0438, // [sharp] hardware — arrow, code, command, computer, control key
    'keyboard_control_outlined':
        0xf1e7, // [outline] navigation — 3, additional, bar menu, choices, content menu
    'keyboard_control_rounded':
        0xf8d9, // [round] navigation — 3, additional, bar menu, choices, content menu
    'keyboard_control_sharp':
        0xeafa, // [sharp] navigation — 3, additional, bar menu, choices, content menu
    'keyboard_double_arrow_down':
        0xf052f, // hardware — advance, angle, arrow, arrows, bottom
    'keyboard_double_arrow_down_outlined':
        0xf0627, // [outline] hardware — advance, angle, arrow, arrows, bottom
    'keyboard_double_arrow_down_rounded':
        0xf0346, // [round] hardware — advance, angle, arrow, arrows, bottom
    'keyboard_double_arrow_down_sharp':
        0xf0439, // [sharp] hardware — advance, angle, arrow, arrows, bottom
    'keyboard_double_arrow_left':
        0xf0530, // hardware — angle left, arrow, arrow left, arrows, back
    'keyboard_double_arrow_left_outlined':
        0xf0628, // [outline] hardware — angle left, arrow, arrow left, arrows, back
    'keyboard_double_arrow_left_rounded':
        0xf0347, // [round] hardware — angle left, arrow, arrow left, arrows, back
    'keyboard_double_arrow_left_sharp':
        0xf043a, // [sharp] hardware — angle left, arrow, arrow left, arrows, back
    'keyboard_double_arrow_right':
        0xf0531, // hardware — accelerate, advance, arrow, arrows, chevron
    'keyboard_double_arrow_right_outlined':
        0xf0629, // [outline] hardware — accelerate, advance, arrow, arrows, chevron
    'keyboard_double_arrow_right_rounded':
        0xf0348, // [round] hardware — accelerate, advance, arrow, arrows, chevron
    'keyboard_double_arrow_right_sharp':
        0xf043b, // [sharp] hardware — accelerate, advance, arrow, arrows, chevron
    'keyboard_double_arrow_up':
        0xf0532, // hardware — arrow, arrow up, arrows, caret, chevron
    'keyboard_double_arrow_up_outlined':
        0xf062a, // [outline] hardware — arrow, arrow up, arrows, caret, chevron
    'keyboard_double_arrow_up_rounded':
        0xf0349, // [round] hardware — arrow, arrow up, arrows, caret, chevron
    'keyboard_double_arrow_up_sharp':
        0xf043c, // [sharp] hardware — arrow, arrow up, arrows, caret, chevron
    'keyboard_hide':
        0xe359, // hardware — arrow, chevron, close, collapse, computer
    'keyboard_hide_outlined':
        0xf143, // [outline] hardware — arrow, chevron, close, collapse, computer
    'keyboard_hide_rounded':
        0xf831, // [round] hardware — arrow, chevron, close, collapse, computer
    'keyboard_hide_sharp':
        0xea52, // [sharp] hardware — arrow, chevron, close, collapse, computer
    'keyboard_option_key':
        0xf0533, // hardware — accessibility, alt, alt key, alternate, character
    'keyboard_option_key_outlined':
        0xf062b, // [outline] hardware — accessibility, alt, alt key, alternate, character
    'keyboard_option_key_rounded':
        0xf034a, // [round] hardware — accessibility, alt, alt key, alternate, character
    'keyboard_option_key_sharp':
        0xf043d, // [sharp] hardware — accessibility, alt, alt key, alternate, character
    'keyboard_outlined':
        0xf144, // [outline] hardware — access, chat, code, communication, computer
    'keyboard_return':
        0xe35a, // hardware — angle, arrow, back, bend, break line
    'keyboard_return_outlined':
        0xf145, // [outline] hardware — angle, arrow, back, bend, break line
    'keyboard_return_rounded':
        0xf832, // [round] hardware — angle, arrow, back, bend, break line
    'keyboard_return_sharp':
        0xea53, // [sharp] hardware — angle, arrow, back, bend, break line
    'keyboard_rounded':
        0xf833, // [round] hardware — access, chat, code, communication, computer
    'keyboard_sharp':
        0xea54, // [sharp] hardware — access, chat, code, communication, computer
    'keyboard_tab':
        0xe35b, // hardware — arrow, character, computer, document, editing
    'keyboard_tab_outlined':
        0xf146, // [outline] hardware — arrow, character, computer, document, editing
    'keyboard_tab_rounded':
        0xf834, // [round] hardware — arrow, character, computer, document, editing
    'keyboard_tab_sharp':
        0xea55, // [sharp] hardware — arrow, character, computer, document, editing
    'keyboard_voice':
        0xe35c, // hardware — audio, audio button, audio capture, audio input, audio recording
    'keyboard_voice_outlined':
        0xf147, // [outline] hardware — audio, audio button, audio capture, audio input, audio recording
    'keyboard_voice_rounded':
        0xf835, // [round] hardware — audio, audio button, audio capture, audio input, audio recording
    'keyboard_voice_sharp':
        0xea56, // [sharp] hardware — audio, audio button, audio capture, audio input, audio recording
    'king_bed':
        0xe35d, // social — accommodation, apartment, bed, bedroom, building
    'king_bed_outlined':
        0xf148, // [outline] social — accommodation, apartment, bed, bedroom, building
    'king_bed_rounded':
        0xf836, // [round] social — accommodation, apartment, bed, bedroom, building
    'king_bed_sharp':
        0xea57, // [sharp] social — accommodation, apartment, bed, bedroom, building
    'kitchen':
        0xe35e, // places — appliance, appliances, building, building structure, cabinets
    'kitchen_outlined':
        0xf149, // [outline] places — appliance, appliances, building, building structure, cabinets
    'kitchen_rounded':
        0xf837, // [round] places — appliance, appliances, building, building structure, cabinets
    'kitchen_sharp':
        0xea58, // [sharp] places — appliance, appliances, building, building structure, cabinets
    'kitesurfing':
        0xe35f, // social — activity, adventure, athlete, athletic, beach
    'kitesurfing_outlined':
        0xf14a, // [outline] social — activity, adventure, athlete, athletic, beach
    'kitesurfing_rounded':
        0xf838, // [round] social — activity, adventure, athlete, athletic, beach
    'kitesurfing_sharp':
        0xea59, // [sharp] social — activity, adventure, athlete, athletic, beach
    'label':
        0xe360, // action — angled shape, badge, bookmark, category, classification
    'label_important':
        0xe361, // action — angled, bookmark, categorization, categorize, chevron
    'label_important_outline':
        0xe362, // action — angled, bookmark, categorization, categorize, corner
    'label_important_outline_rounded':
        0xf839, // [round] action — angled, bookmark, categorization, categorize, corner
    'label_important_outline_sharp':
        0xea5a, // [sharp] action — angled, bookmark, categorization, categorize, corner
    'label_important_outlined':
        0xf14b, // [outline] action — angled, bookmark, categorization, categorize, chevron
    'label_important_rounded':
        0xf83a, // [round] action — angled, bookmark, categorization, categorize, chevron
    'label_important_sharp':
        0xea5b, // [sharp] action — angled, bookmark, categorization, categorize, chevron
    'label_off':
        0xe363, // action — angles, badge off, deactivate label, disable, disable label
    'label_off_outlined':
        0xf14c, // [outline] action — angles, badge off, deactivate label, disable, disable label
    'label_off_rounded':
        0xf83b, // [round] action — angles, badge off, deactivate label, disable, disable label
    'label_off_sharp':
        0xea5c, // [sharp] action — angles, badge off, deactivate label, disable, disable label
    'label_outline':
        0xe364, // action — angled shape, badge, bookmark, category, classification
    'label_outline_rounded':
        0xf83c, // [round] action — angled shape, badge, bookmark, category, classification
    'label_outline_sharp':
        0xea5d, // [sharp] action — angled shape, badge, bookmark, category, classification
    'label_outlined':
        0xf14d, // [outline] action — angled shape, badge, bookmark, category, classification
    'label_rounded':
        0xf83d, // [round] action — angled shape, badge, bookmark, category, classification
    'label_sharp':
        0xea5e, // [sharp] action — angled shape, badge, bookmark, category, classification
    'lan':
        0xf0534, // device — access, business, communication, communications, computer
    'lan_outlined':
        0xf062c, // [outline] device — access, business, communication, communications, computer
    'lan_rounded':
        0xf034b, // [round] device — access, business, communication, communications, computer
    'lan_sharp':
        0xf043e, // [sharp] device — access, business, communication, communications, computer
    'landscape':
        0xe365, // image — chart, contour, diagram, elevation, environment
    'landscape_outlined':
        0xf14e, // [outline] image — chart, contour, diagram, elevation, environment
    'landscape_rounded':
        0xf83e, // [round] image — chart, contour, diagram, elevation, environment
    'landscape_sharp':
        0xea5f, // [sharp] image — chart, contour, diagram, elevation, environment
    'landslide': 0xf07a6, // social — accident, alert, caution, collapse, crisis
    'landslide_outlined':
        0xf06f6, // [outline] social — accident, alert, caution, collapse, crisis
    'landslide_rounded':
        0xf07fe, // [round] social — accident, alert, caution, collapse, crisis
    'landslide_sharp':
        0xf074e, // [sharp] social — accident, alert, caution, collapse, crisis
    'language':
        0xe366, // action — announcement, bubble, caption, chat, communicate
    'language_outlined':
        0xf14f, // [outline] action — announcement, bubble, caption, chat, communicate
    'language_rounded':
        0xf83f, // [round] action — announcement, bubble, caption, chat, communicate
    'language_sharp':
        0xea60, // [sharp] action — announcement, bubble, caption, chat, communicate
    'laptop':
        0xe367, // hardware — Android, OS, accessory, chrome, communication
    'laptop_chromebook':
        0xe368, // hardware — Android, OS, angled, chrome, chromebook
    'laptop_chromebook_outlined':
        0xf150, // [outline] hardware — Android, OS, angled, chrome, chromebook
    'laptop_chromebook_rounded':
        0xf840, // [round] hardware — Android, OS, angled, chrome, chromebook
    'laptop_chromebook_sharp':
        0xea61, // [sharp] hardware — Android, OS, angled, chrome, chromebook
    'laptop_mac': 0xe369, // hardware — Android, OS, chrome, computer, computing
    'laptop_mac_outlined':
        0xf151, // [outline] hardware — Android, OS, chrome, computer, computing
    'laptop_mac_rounded':
        0xf841, // [round] hardware — Android, OS, chrome, computer, computing
    'laptop_mac_sharp':
        0xea62, // [sharp] hardware — Android, OS, chrome, computer, computing
    'laptop_outlined':
        0xf152, // [outline] hardware — Android, OS, accessory, chrome, communication
    'laptop_rounded':
        0xf842, // [round] hardware — Android, OS, accessory, chrome, communication
    'laptop_sharp':
        0xea63, // [sharp] hardware — Android, OS, accessory, chrome, communication
    'laptop_windows':
        0xe36a, // hardware — Android, OS, angled, chrome, computer
    'laptop_windows_outlined':
        0xf153, // [outline] hardware — Android, OS, angled, chrome, computer
    'laptop_windows_rounded':
        0xf843, // [round] hardware — Android, OS, angled, chrome, computer
    'laptop_windows_sharp':
        0xea64, // [sharp] hardware — Android, OS, angled, chrome, computer
    'last_page':
        0xe36b, // navigation — advance, arrow, boundary, chevron, double arrow
    'last_page_outlined':
        0xf154, // [outline] navigation — advance, arrow, boundary, chevron, double arrow
    'last_page_rounded':
        0xf844, // [round] navigation — advance, arrow, boundary, chevron, double arrow
    'last_page_sharp':
        0xea65, // [sharp] navigation — advance, arrow, boundary, chevron, double arrow
    'launch': 0xe36c, // action — access, arrow, box, depart, destination
    'launch_outlined':
        0xf155, // [outline] action — access, arrow, box, depart, destination
    'launch_rounded':
        0xf845, // [round] action — access, arrow, box, depart, destination
    'launch_sharp':
        0xea66, // [sharp] action — access, arrow, box, depart, destination
    'layers': 0xe36d, // maps — arrange, composition, content, depth, disabled
    'layers_clear': 0xe36e, // maps — 3d, arrange, cancel, clear, delete
    'layers_clear_outlined':
        0xf156, // [outline] maps — 3d, arrange, cancel, clear, delete
    'layers_clear_rounded':
        0xf846, // [round] maps — 3d, arrange, cancel, clear, delete
    'layers_clear_sharp':
        0xea67, // [sharp] maps — 3d, arrange, cancel, clear, delete
    'layers_outlined':
        0xf157, // [outline] maps — arrange, composition, content, depth, disabled
    'layers_rounded':
        0xf847, // [round] maps — arrange, composition, content, depth, disabled
    'layers_sharp':
        0xea68, // [sharp] maps — arrange, composition, content, depth, disabled
    'leaderboard':
        0xe36f, // action — achievement, achievements, analytics, bar, bar chart
    'leaderboard_outlined':
        0xf158, // [outline] action — achievement, achievements, analytics, bar, bar chart
    'leaderboard_rounded':
        0xf848, // [round] action — achievement, achievements, analytics, bar, bar chart
    'leaderboard_sharp':
        0xea69, // [sharp] action — achievement, achievements, analytics, bar, bar chart
    'leak_add': 0xe370, // image — add, assembly, attach, build, connect
    'leak_add_outlined':
        0xf159, // [outline] image — add, assembly, attach, build, connect
    'leak_add_rounded':
        0xf849, // [round] image — add, assembly, attach, build, connect
    'leak_add_sharp':
        0xea6a, // [sharp] image — add, assembly, attach, build, connect
    'leak_remove':
        0xe371, // image — anti leak, blocked, cancel, connection, delete
    'leak_remove_outlined':
        0xf15a, // [outline] image — anti leak, blocked, cancel, connection, delete
    'leak_remove_rounded':
        0xf84a, // [round] image — anti leak, blocked, cancel, connection, delete
    'leak_remove_sharp':
        0xea6b, // [sharp] image — anti leak, blocked, cancel, connection, delete
    'leave_bags_at_home': 0xe439,
    'leave_bags_at_home_outlined': 0xf21f,
    'leave_bags_at_home_rounded': 0xf0011,
    'leave_bags_at_home_sharp': 0xeb32,
    'legend_toggle':
        0xe372, // navigation — analytics, box, chart, collapse, description
    'legend_toggle_outlined':
        0xf15b, // [outline] navigation — analytics, box, chart, collapse, description
    'legend_toggle_rounded':
        0xf84b, // [round] navigation — analytics, box, chart, collapse, description
    'legend_toggle_sharp':
        0xea6c, // [sharp] navigation — analytics, box, chart, collapse, description
    'lens': 0xe373, // image — active, angle, badge, centralized, circle
    'lens_blur':
        0xe374, // device — abstract, aperture, artistic effect, blur, bokeh
    'lens_blur_outlined':
        0xf15c, // [outline] device — abstract, aperture, artistic effect, blur, bokeh
    'lens_blur_rounded':
        0xf84c, // [round] device — abstract, aperture, artistic effect, blur, bokeh
    'lens_blur_sharp':
        0xea6d, // [sharp] device — abstract, aperture, artistic effect, blur, bokeh
    'lens_outlined':
        0xf15d, // [outline] image — active, angle, badge, centralized, circle
    'lens_rounded':
        0xf84d, // [round] image — active, angle, badge, centralized, circle
    'lens_sharp':
        0xea6e, // [sharp] image — active, angle, badge, centralized, circle
    'library_add': 0xe375, // av — +, add, archive, book, catalog
    'library_add_check': 0xe376, // av — add, approve, archive, bookmark, box
    'library_add_check_outlined':
        0xf15e, // [outline] av — add, approve, archive, bookmark, box
    'library_add_check_rounded':
        0xf84e, // [round] av — add, approve, archive, bookmark, box
    'library_add_check_sharp':
        0xea6f, // [sharp] av — add, approve, archive, bookmark, box
    'library_add_outlined':
        0xf15f, // [outline] av — +, add, archive, book, catalog
    'library_add_rounded':
        0xf84f, // [round] av — +, add, archive, book, catalog
    'library_add_sharp': 0xea70, // [sharp] av — +, add, archive, book, catalog
    'library_books': 0xe377, // av — academy, add, album, archives, audio
    'library_books_outlined':
        0xf160, // [outline] av — academy, add, album, archives, audio
    'library_books_rounded':
        0xf850, // [round] av — academy, add, album, archives, audio
    'library_books_sharp':
        0xea71, // [sharp] av — academy, add, album, archives, audio
    'library_music':
        0xe378, // av — add, album, archive, audio, audio collection
    'library_music_outlined':
        0xf161, // [outline] av — add, album, archive, audio, audio collection
    'library_music_rounded':
        0xf851, // [round] av — add, album, archive, audio, audio collection
    'library_music_sharp':
        0xea72, // [sharp] av — add, album, archive, audio, audio collection
    'light': 0xe379, // search — abstract, adjust, bright, brightness, bulb
    'light_mode':
        0xe37a, // device — adjustment, appearance, bright, brightness, celestial body
    'light_mode_outlined':
        0xf162, // [outline] device — adjustment, appearance, bright, brightness, celestial body
    'light_mode_rounded':
        0xf852, // [round] device — adjustment, appearance, bright, brightness, celestial body
    'light_mode_sharp':
        0xea73, // [sharp] device — adjustment, appearance, bright, brightness, celestial body
    'light_outlined':
        0xf163, // [outline] search — abstract, adjust, bright, brightness, bulb
    'light_rounded':
        0xf853, // [round] search — abstract, adjust, bright, brightness, bulb
    'light_sharp':
        0xea74, // [sharp] search — abstract, adjust, bright, brightness, bulb
    'lightbulb': 0xe37b, // action — alert, announcement, bright, bulb, concept
    'lightbulb_circle':
        0xf07a7, // action — alert, announcement, bright, bulb, circle
    'lightbulb_circle_outlined':
        0xf06f7, // [outline] action — alert, announcement, bright, bulb, circle
    'lightbulb_circle_rounded':
        0xf07ff, // [round] action — alert, announcement, bright, bulb, circle
    'lightbulb_circle_sharp':
        0xf074f, // [sharp] action — alert, announcement, bright, bulb, circle
    'lightbulb_outline':
        0xe37c, // action — alert, announcement, bright, bulb, concept
    'lightbulb_outline_rounded':
        0xf854, // [round] action — alert, announcement, bright, bulb, concept
    'lightbulb_outline_sharp':
        0xea75, // [sharp] action — alert, announcement, bright, bulb, concept
    'lightbulb_outlined':
        0xf164, // [outline] action — alert, announcement, bright, bulb, concept
    'lightbulb_rounded':
        0xf855, // [round] action — alert, announcement, bright, bulb, concept
    'lightbulb_sharp':
        0xea76, // [sharp] action — alert, announcement, bright, bulb, concept
    'line_axis':
        0xf0535, // editor — accuracy, analytics, axis, chart, coordinate system
    'line_axis_outlined':
        0xf062d, // [outline] editor — accuracy, analytics, axis, chart, coordinate system
    'line_axis_rounded':
        0xf034c, // [round] editor — accuracy, analytics, axis, chart, coordinate system
    'line_axis_sharp':
        0xf043f, // [sharp] editor — accuracy, analytics, axis, chart, coordinate system
    'line_style':
        0xe37d, // action — adjust, alignment, bullet points, content, customize
    'line_style_outlined':
        0xf165, // [outline] action — adjust, alignment, bullet points, content, customize
    'line_style_rounded':
        0xf856, // [round] action — adjust, alignment, bullet points, content, customize
    'line_style_sharp':
        0xea77, // [sharp] action — adjust, alignment, bullet points, content, customize
    'line_weight':
        0xe37e, // action — adjust, bars, content, different sizes, document
    'line_weight_outlined':
        0xf166, // [outline] action — adjust, bars, content, different sizes, document
    'line_weight_rounded':
        0xf857, // [round] action — adjust, bars, content, different sizes, document
    'line_weight_sharp':
        0xea78, // [sharp] action — adjust, bars, content, different sizes, document
    'linear_scale':
        0xe37f, // editor — adjust, adjustment, calibrate, configuration, degree
    'linear_scale_outlined':
        0xf167, // [outline] editor — adjust, adjustment, calibrate, configuration, degree
    'linear_scale_rounded':
        0xf858, // [round] editor — adjust, adjustment, calibrate, configuration, degree
    'linear_scale_sharp':
        0xea79, // [sharp] editor — adjust, adjustment, calibrate, configuration, degree
    'link': 0xe380, // content — anchor, arrow, attach, attachment, chain
    'link_off':
        0xe381, // content — attached, broken chain, broken connection, broken hyperlink, broken link
    'link_off_outlined':
        0xf168, // [outline] content — attached, broken chain, broken connection, broken hyperlink, broken link
    'link_off_rounded':
        0xf859, // [round] content — attached, broken chain, broken connection, broken hyperlink, broken link
    'link_off_sharp':
        0xea7a, // [sharp] content — attached, broken chain, broken connection, broken hyperlink, broken link
    'link_outlined':
        0xf169, // [outline] content — anchor, arrow, attach, attachment, chain
    'link_rounded':
        0xf85a, // [round] content — anchor, arrow, attach, attachment, chain
    'link_sharp':
        0xea7b, // [sharp] content — anchor, arrow, attach, attachment, chain
    'linked_camera':
        0xe382, // image — attached, camera, capture, chain, connect
    'linked_camera_outlined':
        0xf16a, // [outline] image — attached, camera, capture, chain, connect
    'linked_camera_rounded':
        0xf85b, // [round] image — attached, camera, capture, chain, connect
    'linked_camera_sharp':
        0xea7c, // [sharp] image — attached, camera, capture, chain, connect
    'liquor': 0xe383, // maps — alcohol, bar, beverage, bottle, celebration
    'liquor_outlined':
        0xf16b, // [outline] maps — alcohol, bar, beverage, bottle, celebration
    'liquor_rounded':
        0xf85c, // [round] maps — alcohol, bar, beverage, bottle, celebration
    'liquor_sharp':
        0xea7d, // [sharp] maps — alcohol, bar, beverage, bottle, celebration
    'list':
        0xe384, // action — agenda, bullet points, bulleted list, catalog, checklist
    'list_alt': 0xe385, // communication — agenda, alt, box, bullet, bullet-list
    'list_alt_outlined':
        0xf16c, // [outline] communication — agenda, alt, box, bullet, bullet-list
    'list_alt_rounded':
        0xf85d, // [round] communication — agenda, alt, box, bullet, bullet-list
    'list_alt_sharp':
        0xea7e, // [sharp] communication — agenda, alt, box, bullet, bullet-list
    'list_outlined':
        0xf16d, // [outline] action — agenda, bullet points, bulleted list, catalog, checklist
    'list_rounded':
        0xf85e, // [round] action — agenda, bullet points, bulleted list, catalog, checklist
    'list_sharp':
        0xea7f, // [sharp] action — agenda, bullet points, bulleted list, catalog, checklist
    'live_help': 0xe386, // communication — ?, advice, aid, answer, assistance
    'live_help_outlined':
        0xf16e, // [outline] communication — ?, advice, aid, answer, assistance
    'live_help_rounded':
        0xf85f, // [round] communication — ?, advice, aid, answer, assistance
    'live_help_sharp':
        0xea80, // [sharp] communication — ?, advice, aid, answer, assistance
    'live_tv':
        0xe387, // notification — Android, OS, antenna, antennas hardware, broadcast
    'live_tv_outlined':
        0xf16f, // [outline] notification — Android, OS, antenna, antennas hardware, broadcast
    'live_tv_rounded':
        0xf860, // [round] notification — Android, OS, antenna, antennas hardware, broadcast
    'live_tv_sharp':
        0xea81, // [sharp] notification — Android, OS, antenna, antennas hardware, broadcast
    'living': 0xe388, // search — account, avatar, bust, chair, comfort
    'living_outlined':
        0xf170, // [outline] search — account, avatar, bust, chair, comfort
    'living_rounded':
        0xf861, // [round] search — account, avatar, bust, chair, comfort
    'living_sharp':
        0xea82, // [sharp] search — account, avatar, bust, chair, comfort
    'local_activity':
        0xe389, // maps — access, activity, admission, attendance, cinema
    'local_activity_outlined':
        0xf171, // [outline] maps — access, activity, admission, attendance, cinema
    'local_activity_rounded':
        0xf862, // [round] maps — access, activity, admission, attendance, cinema
    'local_activity_sharp':
        0xea83, // [sharp] maps — access, activity, admission, attendance, cinema
    'local_airport':
        0xe38a, // maps — active, air, air travel, aircraft, airplane
    'local_airport_outlined':
        0xf172, // [outline] maps — active, air, air travel, aircraft, airplane
    'local_airport_rounded':
        0xf863, // [round] maps — active, air, air travel, aircraft, airplane
    'local_airport_sharp':
        0xea84, // [sharp] maps — active, air, air travel, aircraft, airplane
    'local_atm': 0xe38b, // maps — atm, bank, banking, bill, brick and mortar
    'local_atm_outlined':
        0xf173, // [outline] maps — atm, bank, banking, bill, brick and mortar
    'local_atm_rounded':
        0xf864, // [round] maps — atm, bank, banking, bill, brick and mortar
    'local_atm_sharp':
        0xea85, // [sharp] maps — atm, bank, banking, bill, brick and mortar
    'local_attraction':
        0xe389, // maps — access, activity, admission, attendance, cinema
    'local_attraction_outlined':
        0xf171, // [outline] maps — access, activity, admission, attendance, cinema
    'local_attraction_rounded':
        0xf862, // [round] maps — access, activity, admission, attendance, cinema
    'local_attraction_sharp':
        0xea83, // [sharp] maps — access, activity, admission, attendance, cinema
    'local_bar': 0xe38c, // maps — alcohol, bar, beer, beverage, bottle
    'local_bar_outlined':
        0xf174, // [outline] maps — alcohol, bar, beer, beverage, bottle
    'local_bar_rounded':
        0xf865, // [round] maps — alcohol, bar, beer, beverage, bottle
    'local_bar_sharp':
        0xea86, // [sharp] maps — alcohol, bar, beer, beverage, bottle
    'local_cafe': 0xe38d, // maps — beverage, bottle, break, breakfast, cafe
    'local_cafe_outlined':
        0xf175, // [outline] maps — beverage, bottle, break, breakfast, cafe
    'local_cafe_rounded':
        0xf866, // [round] maps — beverage, bottle, break, breakfast, cafe
    'local_cafe_sharp':
        0xea87, // [sharp] maps — beverage, bottle, break, breakfast, cafe
    'local_car_wash':
        0xe38e, // maps — auto, automobile, brush, bubble, business
    'local_car_wash_outlined':
        0xf176, // [outline] maps — auto, automobile, brush, bubble, business
    'local_car_wash_rounded':
        0xf867, // [round] maps — auto, automobile, brush, bubble, business
    'local_car_wash_sharp':
        0xea88, // [sharp] maps — auto, automobile, brush, bubble, business
    'local_convenience_store': 0xe38f, // maps — --, 24, awning, bill, building
    'local_convenience_store_outlined':
        0xf177, // [outline] maps — --, 24, awning, bill, building
    'local_convenience_store_rounded':
        0xf868, // [round] maps — --, 24, awning, bill, building
    'local_convenience_store_sharp':
        0xea89, // [sharp] maps — --, 24, awning, bill, building
    'local_dining': 0xe390, // maps — bistro, breakfast, cafe, catering, cuisine
    'local_dining_outlined':
        0xf178, // [outline] maps — bistro, breakfast, cafe, catering, cuisine
    'local_dining_rounded':
        0xf869, // [round] maps — bistro, breakfast, cafe, catering, cuisine
    'local_dining_sharp':
        0xea8a, // [sharp] maps — bistro, breakfast, cafe, catering, cuisine
    'local_drink': 0xe391, // maps — alcohol, bar, beverage, cafe, catering
    'local_drink_outlined':
        0xf179, // [outline] maps — alcohol, bar, beverage, cafe, catering
    'local_drink_rounded':
        0xf86a, // [round] maps — alcohol, bar, beverage, cafe, catering
    'local_drink_sharp':
        0xea8b, // [sharp] maps — alcohol, bar, beverage, cafe, catering
    'local_fire_department':
        0xe392, // maps — 911, alert, blaze, burning, climate
    'local_fire_department_outlined':
        0xf17a, // [outline] maps — 911, alert, blaze, burning, climate
    'local_fire_department_rounded':
        0xf86b, // [round] maps — 911, alert, blaze, burning, climate
    'local_fire_department_sharp':
        0xea8c, // [sharp] maps — 911, alert, blaze, burning, climate
    'local_florist': 0xe393, // maps — beauty, bloom, blooming, blossom, botany
    'local_florist_outlined':
        0xf17b, // [outline] maps — beauty, bloom, blooming, blossom, botany
    'local_florist_rounded':
        0xf86c, // [round] maps — beauty, bloom, blooming, blossom, botany
    'local_florist_sharp':
        0xea8d, // [sharp] maps — beauty, bloom, blooming, blossom, botany
    'local_gas_station': 0xe394, // maps — area, auto, automotive, car, diesel
    'local_gas_station_outlined':
        0xf17c, // [outline] maps — area, auto, automotive, car, diesel
    'local_gas_station_rounded':
        0xf86d, // [round] maps — area, auto, automotive, car, diesel
    'local_gas_station_sharp':
        0xea8e, // [sharp] maps — area, auto, automotive, car, diesel
    'local_grocery_store':
        0xe395, // maps — add to cart, basket, buy, buying, carriage
    'local_grocery_store_outlined':
        0xf17d, // [outline] maps — add to cart, basket, buy, buying, carriage
    'local_grocery_store_rounded':
        0xf86e, // [round] maps — add to cart, basket, buy, buying, carriage
    'local_grocery_store_sharp':
        0xea8f, // [sharp] maps — add to cart, basket, buy, buying, carriage
    'local_hospital': 0xe396, // maps — 911, aid, ambulance, building, care
    'local_hospital_outlined':
        0xf17e, // [outline] maps — 911, aid, ambulance, building, care
    'local_hospital_rounded':
        0xf86f, // [round] maps — 911, aid, ambulance, building, care
    'local_hospital_sharp':
        0xea90, // [sharp] maps — 911, aid, ambulance, building, care
    'local_hotel':
        0xe397, // maps — accommodation, apartment, bed, body, booking
    'local_hotel_outlined':
        0xf17f, // [outline] maps — accommodation, apartment, bed, body, booking
    'local_hotel_rounded':
        0xf870, // [round] maps — accommodation, apartment, bed, body, booking
    'local_hotel_sharp':
        0xea91, // [sharp] maps — accommodation, apartment, bed, body, booking
    'local_laundry_service':
        0xe398, // maps — amenity, apparel, bubble, bubbles, business
    'local_laundry_service_outlined':
        0xf180, // [outline] maps — amenity, apparel, bubble, bubbles, business
    'local_laundry_service_rounded':
        0xf871, // [round] maps — amenity, apparel, bubble, bubbles, business
    'local_laundry_service_sharp':
        0xea92, // [sharp] maps — amenity, apparel, bubble, bubbles, business
    'local_library':
        0xe399, // maps — academy, archive, book, book stack, book symbol
    'local_library_outlined':
        0xf181, // [outline] maps — academy, archive, book, book stack, book symbol
    'local_library_rounded':
        0xf872, // [round] maps — academy, archive, book, book stack, book symbol
    'local_library_sharp':
        0xea93, // [sharp] maps — academy, archive, book, book stack, book symbol
    'local_mall': 0xe39a, // maps — bag, basket, bill, boutique, building
    'local_mall_outlined':
        0xf182, // [outline] maps — bag, basket, bill, boutique, building
    'local_mall_rounded':
        0xf873, // [round] maps — bag, basket, bill, boutique, building
    'local_mall_sharp':
        0xea94, // [sharp] maps — bag, basket, bill, boutique, building
    'local_movies':
        0xe39b, // maps — box office, cinema, clip, documentary, entertainment
    'local_movies_outlined':
        0xf183, // [outline] maps — box office, cinema, clip, documentary, entertainment
    'local_movies_rounded':
        0xf874, // [round] maps — box office, cinema, clip, documentary, entertainment
    'local_movies_sharp':
        0xea95, // [sharp] maps — box office, cinema, clip, documentary, entertainment
    'local_offer': 0xe39c, // maps — bargain, commerce, coupon, deal, discount
    'local_offer_outlined':
        0xf184, // [outline] maps — bargain, commerce, coupon, deal, discount
    'local_offer_rounded':
        0xf875, // [round] maps — bargain, commerce, coupon, deal, discount
    'local_offer_sharp':
        0xea96, // [sharp] maps — bargain, commerce, coupon, deal, discount
    'local_parking': 0xe39d, // maps — alphabet, auto, block, car, character
    'local_parking_outlined':
        0xf185, // [outline] maps — alphabet, auto, block, car, character
    'local_parking_rounded':
        0xf876, // [round] maps — alphabet, auto, block, car, character
    'local_parking_sharp':
        0xea97, // [sharp] maps — alphabet, auto, block, car, character
    'local_pharmacy': 0xe39e, // maps — 911, aid, building, clinic, cross
    'local_pharmacy_outlined':
        0xf186, // [outline] maps — 911, aid, building, clinic, cross
    'local_pharmacy_rounded':
        0xf877, // [round] maps — 911, aid, building, clinic, cross
    'local_pharmacy_sharp':
        0xea98, // [sharp] maps — 911, aid, building, clinic, cross
    'local_phone': 0xe39f, // maps — audio, booth, business, call, communication
    'local_phone_outlined':
        0xf187, // [outline] maps — audio, booth, business, call, communication
    'local_phone_rounded':
        0xf878, // [round] maps — audio, booth, business, call, communication
    'local_phone_sharp':
        0xea99, // [sharp] maps — audio, booth, business, call, communication
    'local_pizza': 0xe3a0, // maps — catering, cheese, circle, circular, cooking
    'local_pizza_outlined':
        0xf188, // [outline] maps — catering, cheese, circle, circular, cooking
    'local_pizza_rounded':
        0xf879, // [round] maps — catering, cheese, circle, circular, cooking
    'local_pizza_sharp':
        0xea9a, // [sharp] maps — catering, cheese, circle, circular, cooking
    'local_play':
        0xe3a1, // maps — access, activity, admission, attendance, cinema
    'local_play_outlined':
        0xf189, // [outline] maps — access, activity, admission, attendance, cinema
    'local_play_rounded':
        0xf87a, // [round] maps — access, activity, admission, attendance, cinema
    'local_play_sharp':
        0xea9b, // [sharp] maps — access, activity, admission, attendance, cinema
    'local_police':
        0xe3a2, // maps — 911, authority, authority symbol, badge, crime
    'local_police_outlined':
        0xf18a, // [outline] maps — 911, authority, authority symbol, badge, crime
    'local_police_rounded':
        0xf87b, // [round] maps — 911, authority, authority symbol, badge, crime
    'local_police_sharp':
        0xea9c, // [sharp] maps — 911, authority, authority symbol, badge, crime
    'local_post_office':
        0xe3a3, // maps — address, building, building exterior, business, communication
    'local_post_office_outlined':
        0xf18b, // [outline] maps — address, building, building exterior, business, communication
    'local_post_office_rounded':
        0xf87c, // [round] maps — address, building, building exterior, business, communication
    'local_post_office_sharp':
        0xea9d, // [sharp] maps — address, building, building exterior, business, communication
    'local_print_shop': 0xe3a4,
    'local_print_shop_outlined': 0xf18c,
    'local_print_shop_rounded': 0xf87d,
    'local_print_shop_sharp': 0xea9e,
    'local_printshop': 0xe3a4, // maps — copier, copy, device, document, draft
    'local_printshop_outlined':
        0xf18c, // [outline] maps — copier, copy, device, document, draft
    'local_printshop_rounded':
        0xf87d, // [round] maps — copier, copy, device, document, draft
    'local_printshop_sharp':
        0xea9e, // [sharp] maps — copier, copy, device, document, draft
    'local_restaurant':
        0xe390, // maps — bar, breakfast, breakfast place, building, cafe
    'local_restaurant_outlined':
        0xf178, // [outline] maps — bar, breakfast, breakfast place, building, cafe
    'local_restaurant_rounded':
        0xf869, // [round] maps — bar, breakfast, breakfast place, building, cafe
    'local_restaurant_sharp':
        0xea8a, // [sharp] maps — bar, breakfast, breakfast place, building, cafe
    'local_see': 0xe3a5, // maps — camera, capture, cinema, event, film
    'local_see_outlined':
        0xf18d, // [outline] maps — camera, capture, cinema, event, film
    'local_see_rounded':
        0xf87e, // [round] maps — camera, capture, cinema, event, film
    'local_see_sharp':
        0xea9f, // [sharp] maps — camera, capture, cinema, event, film
    'local_shipping': 0xe3a6, // maps — automobile, box, business, car, cargo
    'local_shipping_outlined':
        0xf18e, // [outline] maps — automobile, box, business, car, cargo
    'local_shipping_rounded':
        0xf87f, // [round] maps — automobile, box, business, car, cargo
    'local_shipping_sharp':
        0xeaa0, // [sharp] maps — automobile, box, business, car, cargo
    'local_taxi': 0xe3a7, // maps — appointment, auto, automobile, booking, cab
    'local_taxi_outlined':
        0xf18f, // [outline] maps — appointment, auto, automobile, booking, cab
    'local_taxi_rounded':
        0xf880, // [round] maps — appointment, auto, automobile, booking, cab
    'local_taxi_sharp':
        0xeaa1, // [sharp] maps — appointment, auto, automobile, booking, cab
    'location_city':
        0xe3a8, // social — apartments, architecture, area, building, buildings
    'location_city_outlined':
        0xf190, // [outline] social — apartments, architecture, area, building, buildings
    'location_city_rounded':
        0xf881, // [round] social — apartments, architecture, area, building, buildings
    'location_city_sharp':
        0xeaa2, // [sharp] social — apartments, architecture, area, building, buildings
    'location_disabled':
        0xe3a9, // device — access denied, alert, blocked, circle, cross
    'location_disabled_outlined':
        0xf191, // [outline] device — access denied, alert, blocked, circle, cross
    'location_disabled_rounded':
        0xf882, // [round] device — access denied, alert, blocked, circle, cross
    'location_disabled_sharp':
        0xeaa3, // [sharp] device — access denied, alert, blocked, circle, cross
    'location_history': 0xe498,
    'location_history_outlined': 0xf27d,
    'location_history_rounded': 0xf006e,
    'location_history_sharp': 0xeb8f,
    'location_off':
        0xe3aa, // communication — address, blocked, cross out, denied, destination
    'location_off_outlined':
        0xf192, // [outline] communication — address, blocked, cross out, denied, destination
    'location_off_rounded':
        0xf883, // [round] communication — address, blocked, cross out, denied, destination
    'location_off_sharp':
        0xeaa4, // [sharp] communication — address, blocked, cross out, denied, destination
    'location_on':
        0xe3ab, // communication — address, area, current location, destination, direction
    'location_on_outlined':
        0xf193, // [outline] communication — address, area, current location, destination, direction
    'location_on_rounded':
        0xf884, // [round] communication — address, area, current location, destination, direction
    'location_on_sharp':
        0xeaa5, // [sharp] communication — address, area, current location, destination, direction
    'location_pin':
        0xe3ac, // maps — address, area, current location, destination, direction
    'location_searching':
        0xe3ad, // device — acquire, acquiring, coordinates, current location, destination
    'location_searching_outlined':
        0xf194, // [outline] device — acquire, acquiring, coordinates, current location, destination
    'location_searching_rounded':
        0xf885, // [round] device — acquire, acquiring, coordinates, current location, destination
    'location_searching_sharp':
        0xeaa6, // [sharp] device — acquire, acquiring, coordinates, current location, destination
    'lock':
        0xe3ae, // action — access, authentication, authorization, browser, closed
    'lock_clock':
        0xe3af, // action — access, access control, access time, clock, controlled access
    'lock_clock_outlined':
        0xf195, // [outline] action — access, access control, access time, clock, controlled access
    'lock_clock_rounded':
        0xf886, // [round] action — access, access control, access time, clock, controlled access
    'lock_clock_sharp':
        0xeaa7, // [sharp] action — access, access control, access time, clock, controlled access
    'lock_open':
        0xe3b0, // action — access, action open, authorized, button open, control open
    'lock_open_outlined':
        0xf196, // [outline] action — access, action open, authorized, button open, control open
    'lock_open_rounded':
        0xf887, // [round] action — access, action open, authorized, button open, control open
    'lock_open_sharp':
        0xeaa8, // [sharp] action — access, action open, authorized, button open, control open
    'lock_outline':
        0xe3b1, // action — access, authentication, authorization, browser, closed
    'lock_outline_rounded':
        0xf888, // [round] action — access, authentication, authorization, browser, closed
    'lock_outline_sharp':
        0xeaa9, // [sharp] action — access, authentication, authorization, browser, closed
    'lock_outlined':
        0xf197, // [outline] action — access, authentication, authorization, browser, closed
    'lock_person':
        0xf07a8, // action — access, access control, account, authentication, authorization
    'lock_person_outlined':
        0xf06f8, // [outline] action — access, access control, account, authentication, authorization
    'lock_person_rounded':
        0xf0800, // [round] action — access, access control, account, authentication, authorization
    'lock_person_sharp':
        0xf0750, // [sharp] action — access, access control, account, authentication, authorization
    'lock_reset':
        0xf0536, // action — access, around, arrow, authentication, authorization
    'lock_reset_outlined':
        0xf062e, // [outline] action — access, around, arrow, authentication, authorization
    'lock_reset_rounded':
        0xf034d, // [round] action — access, around, arrow, authentication, authorization
    'lock_reset_sharp':
        0xf0440, // [sharp] action — access, around, arrow, authentication, authorization
    'lock_rounded':
        0xf889, // [round] action — access, authentication, authorization, browser, closed
    'lock_sharp':
        0xeaaa, // [sharp] action — access, authentication, authorization, browser, closed
    'login':
        0xe3b2, // action — access, account, arrow, authentication, authorization
    'login_outlined':
        0xf198, // [outline] action — access, account, arrow, authentication, authorization
    'login_rounded':
        0xf88a, // [round] action — access, account, arrow, authentication, authorization
    'login_sharp':
        0xeaab, // [sharp] action — access, account, arrow, authentication, authorization
    'logo_dev': 0xf0537, // image — brand, build, building, business, code
    'logo_dev_outlined':
        0xf062f, // [outline] image — brand, build, building, business, code
    'logo_dev_rounded':
        0xf034e, // [round] image — brand, build, building, business, code
    'logo_dev_sharp':
        0xf0441, // [sharp] image — brand, build, building, business, code
    'logout':
        0xe3b3, // action — access, account, arrow, arrow pointing right, arrow right
    'logout_outlined':
        0xf199, // [outline] action — access, account, arrow, arrow pointing right, arrow right
    'logout_rounded':
        0xf88b, // [round] action — access, account, arrow, arrow pointing right, arrow right
    'logout_sharp':
        0xeaac, // [sharp] action — access, account, arrow, arrow pointing right, arrow right
    'looks':
        0xe3b4, // image — accessory, circle, clarity, enhancement, eyeglasses
    'looks_3': 0xe3b5, // image — 3, arrangement, count, customization, digit
    'looks_3_outlined':
        0xf19a, // [outline] image — 3, arrangement, count, customization, digit
    'looks_3_rounded':
        0xf88c, // [round] image — 3, arrangement, count, customization, digit
    'looks_3_sharp':
        0xeaad, // [sharp] image — 3, arrangement, count, customization, digit
    'looks_4': 0xe3b6, // image — 4, block, block four, count, design
    'looks_4_outlined':
        0xf19b, // [outline] image — 4, block, block four, count, design
    'looks_4_rounded':
        0xf88d, // [round] image — 4, block, block four, count, design
    'looks_4_sharp':
        0xeaae, // [sharp] image — 4, block, block four, count, design
    'looks_5': 0xe3b7, // image — 5, browse, digit, discover, enlarge
    'looks_5_outlined':
        0xf19c, // [outline] image — 5, browse, digit, discover, enlarge
    'looks_5_rounded':
        0xf88e, // [round] image — 5, browse, digit, discover, enlarge
    'looks_5_sharp':
        0xeaaf, // [sharp] image — 5, browse, digit, discover, enlarge
    'looks_6': 0xe3b8, // image — 6, achievement, approval, badge, bookmark
    'looks_6_outlined':
        0xf19d, // [outline] image — 6, achievement, approval, badge, bookmark
    'looks_6_rounded':
        0xf88f, // [round] image — 6, achievement, approval, badge, bookmark
    'looks_6_sharp':
        0xeab0, // [sharp] image — 6, achievement, approval, badge, bookmark
    'looks_one': 0xe3b9, // image — 1, beginning, competition, count, counting
    'looks_one_outlined':
        0xf19e, // [outline] image — 1, beginning, competition, count, counting
    'looks_one_rounded':
        0xf890, // [round] image — 1, beginning, competition, count, counting
    'looks_one_sharp':
        0xeab1, // [sharp] image — 1, beginning, competition, count, counting
    'looks_outlined':
        0xf19f, // [outline] image — accessory, circle, clarity, enhancement, eyeglasses
    'looks_rounded':
        0xf891, // [round] image — accessory, circle, clarity, enhancement, eyeglasses
    'looks_sharp':
        0xeab2, // [sharp] image — accessory, circle, clarity, enhancement, eyeglasses
    'looks_two': 0xe3ba, // image — 2, digit, double, eye, eyes
    'looks_two_outlined':
        0xf1a0, // [outline] image — 2, digit, double, eye, eyes
    'looks_two_rounded': 0xf892, // [round] image — 2, digit, double, eye, eyes
    'looks_two_sharp': 0xeab3, // [sharp] image — 2, digit, double, eye, eyes
    'loop': 0xe3bb, // av — around, arrow, arrows, autorenew, circle
    'loop_outlined':
        0xf1a1, // [outline] av — around, arrow, arrows, autorenew, circle
    'loop_rounded':
        0xf893, // [round] av — around, arrow, arrows, autorenew, circle
    'loop_sharp':
        0xeab4, // [sharp] av — around, arrow, arrows, autorenew, circle
    'loupe': 0xe3bc, // image — +, add, analyze, circle, details
    'loupe_outlined':
        0xf1a2, // [outline] image — +, add, analyze, circle, details
    'loupe_rounded': 0xf894, // [round] image — +, add, analyze, circle, details
    'loupe_sharp': 0xeab5, // [sharp] image — +, add, analyze, circle, details
    'low_priority':
        0xe3bd, // content — arrange, arrow, arrow down, backward, bottom
    'low_priority_outlined':
        0xf1a3, // [outline] content — arrange, arrow, arrow down, backward, bottom
    'low_priority_rounded':
        0xf895, // [round] content — arrange, arrow, arrow down, backward, bottom
    'low_priority_sharp':
        0xeab6, // [sharp] content — arrange, arrow, arrow down, backward, bottom
    'loyalty': 0xe3be, // action — achievement, award, benefit, benefits, best
    'loyalty_outlined':
        0xf1a4, // [outline] action — achievement, award, benefit, benefits, best
    'loyalty_rounded':
        0xf896, // [round] action — achievement, award, benefit, benefits, best
    'loyalty_sharp':
        0xeab7, // [sharp] action — achievement, award, benefit, benefits, best
    'lte_mobiledata': 0xe3bf, // device — access, alphabet, bar, bars, broadband
    'lte_mobiledata_outlined':
        0xf1a5, // [outline] device — access, alphabet, bar, bars, broadband
    'lte_mobiledata_rounded':
        0xf897, // [round] device — access, alphabet, bar, bars, broadband
    'lte_mobiledata_sharp':
        0xeab8, // [sharp] device — access, alphabet, bar, bars, broadband
    'lte_plus_mobiledata':
        0xe3c0, // device — +, alphabet, cell, character, characters
    'lte_plus_mobiledata_outlined':
        0xf1a6, // [outline] device — +, alphabet, cell, character, characters
    'lte_plus_mobiledata_rounded':
        0xf898, // [round] device — +, alphabet, cell, character, characters
    'lte_plus_mobiledata_sharp':
        0xeab9, // [sharp] device — +, alphabet, cell, character, characters
    'luggage': 0xe3c1, // social — airport, bag, baggage, belongings, box
    'luggage_outlined':
        0xf1a7, // [outline] social — airport, bag, baggage, belongings, box
    'luggage_rounded':
        0xf899, // [round] social — airport, bag, baggage, belongings, box
    'luggage_sharp':
        0xeaba, // [sharp] social — airport, bag, baggage, belongings, box
    'lunch_dining':
        0xe3c2, // maps — bar, breakfast, breakfast time, brunch, cafe
    'lunch_dining_outlined':
        0xf1a8, // [outline] maps — bar, breakfast, breakfast time, brunch, cafe
    'lunch_dining_rounded':
        0xf89a, // [round] maps — bar, breakfast, breakfast time, brunch, cafe
    'lunch_dining_sharp':
        0xeabb, // [sharp] maps — bar, breakfast, breakfast time, brunch, cafe
    'lyrics': 0xf07a9, // av — audio, bubble, chat, comment, communicate
    'lyrics_outlined':
        0xf06f9, // [outline] av — audio, bubble, chat, comment, communicate
    'lyrics_rounded':
        0xf0801, // [round] av — audio, bubble, chat, comment, communicate
    'lyrics_sharp':
        0xf0751, // [sharp] av — audio, bubble, chat, comment, communicate
    'macro_off':
        0xf086b, // device — camera, camera off, camera settings, circle, close-up off
    'macro_off_outlined':
        0xf08aa, // [outline] device — camera, camera off, camera settings, circle, close-up off
    'macro_off_rounded':
        0xf088c, // [round] device — camera, camera off, camera settings, circle, close-up off
    'macro_off_sharp':
        0xf0843, // [sharp] device — camera, camera off, camera settings, circle, close-up off
    'mail':
        0xe3c3, // content — communication, contact, correspondence, diagonal lines, digital
    'mail_lock':
        0xf07aa, // communication — access, closed mail, communication, confidential, confidential mail
    'mail_lock_outlined':
        0xf06fa, // [outline] communication — access, closed mail, communication, confidential, confidential mail
    'mail_lock_rounded':
        0xf0802, // [round] communication — access, closed mail, communication, confidential, confidential mail
    'mail_lock_sharp':
        0xf0752, // [sharp] communication — access, closed mail, communication, confidential, confidential mail
    'mail_outline':
        0xe3c4, // communication — communication, contact, correspondence, diagonal lines, digital
    'mail_outline_outlined':
        0xf1a9, // [outline] communication — communication, contact, correspondence, diagonal lines, digital
    'mail_outline_rounded':
        0xf89b, // [round] communication — communication, contact, correspondence, diagonal lines, digital
    'mail_outline_sharp':
        0xeabc, // [sharp] communication — communication, contact, correspondence, diagonal lines, digital
    'mail_outlined':
        0xf1aa, // [outline] content — communication, contact, correspondence, diagonal lines, digital
    'mail_rounded':
        0xf89c, // [round] content — communication, contact, correspondence, diagonal lines, digital
    'mail_sharp':
        0xeabd, // [sharp] content — communication, contact, correspondence, diagonal lines, digital
    'male': 0xe3c5, // social — account, avatar, body, boy, circle
    'male_outlined':
        0xf1ab, // [outline] social — account, avatar, body, boy, circle
    'male_rounded':
        0xf89d, // [round] social — account, avatar, body, boy, circle
    'male_sharp': 0xeabe, // [sharp] social — account, avatar, body, boy, circle
    'man': 0xf0538, // social — account, avatar, body, boy, character
    'man_2': 0xf086c, // social — account, avatar, biography, boy, bust
    'man_2_outlined':
        0xf08ab, // [outline] social — account, avatar, biography, boy, bust
    'man_2_rounded':
        0xf088d, // [round] social — account, avatar, biography, boy, bust
    'man_2_sharp':
        0xf0844, // [sharp] social — account, avatar, biography, boy, bust
    'man_3': 0xf086d, // social — abstract, account, avatar, boy, circle
    'man_3_outlined':
        0xf08ac, // [outline] social — abstract, account, avatar, boy, circle
    'man_3_rounded':
        0xf088e, // [round] social — abstract, account, avatar, boy, circle
    'man_3_sharp':
        0xf0845, // [sharp] social — abstract, account, avatar, boy, circle
    'man_4':
        0xf086e, // social — abstract, account, account management, avatar, boy
    'man_4_outlined':
        0xf08ad, // [outline] social — abstract, account, account management, avatar, boy
    'man_4_rounded':
        0xf088f, // [round] social — abstract, account, account management, avatar, boy
    'man_4_sharp':
        0xf0846, // [sharp] social — abstract, account, account management, avatar, boy
    'man_outlined':
        0xf0630, // [outline] social — account, avatar, body, boy, character
    'man_rounded':
        0xf034f, // [round] social — account, avatar, body, boy, character
    'man_sharp':
        0xf0442, // [sharp] social — account, avatar, body, boy, character
    'manage_accounts':
        0xe3c6, // action — access, accounts, administration, avatar, bust
    'manage_accounts_outlined':
        0xf1ac, // [outline] action — access, accounts, administration, avatar, bust
    'manage_accounts_rounded':
        0xf89e, // [round] action — access, accounts, administration, avatar, bust
    'manage_accounts_sharp':
        0xeabf, // [sharp] action — access, accounts, administration, avatar, bust
    'manage_history':
        0xf07ab, // action — administration, arrangement, arrow, back, backwards
    'manage_history_outlined':
        0xf06fb, // [outline] action — administration, arrangement, arrow, back, backwards
    'manage_history_rounded':
        0xf0803, // [round] action — administration, arrangement, arrow, back, backwards
    'manage_history_sharp':
        0xf0753, // [sharp] action — administration, arrangement, arrow, back, backwards
    'manage_search':
        0xe3c7, // search — administration, configure, discover, explore, filter
    'manage_search_outlined':
        0xf1ad, // [outline] search — administration, configure, discover, explore, filter
    'manage_search_rounded':
        0xf89f, // [round] search — administration, configure, discover, explore, filter
    'manage_search_sharp':
        0xeac0, // [sharp] search — administration, configure, discover, explore, filter
    'map': 0xe3c8, // maps — address, atlas, cartography, city, continent
    'map_outlined':
        0xf1ae, // [outline] maps — address, atlas, cartography, city, continent
    'map_rounded':
        0xf8a0, // [round] maps — address, atlas, cartography, city, continent
    'map_sharp':
        0xeac1, // [sharp] maps — address, atlas, cartography, city, continent
    'maps_home_work':
        0xe3c9, // navigation — address, architecture, building, business, commercial
    'maps_home_work_outlined':
        0xf1af, // [outline] navigation — address, architecture, building, business, commercial
    'maps_home_work_rounded':
        0xf8a1, // [round] navigation — address, architecture, building, business, commercial
    'maps_home_work_sharp':
        0xeac2, // [sharp] navigation — address, architecture, building, business, commercial
    'maps_ugc': 0xe3ca, // maps — +, add, add data, bubble, cartography
    'maps_ugc_outlined':
        0xf1b0, // [outline] maps — +, add, add data, bubble, cartography
    'maps_ugc_rounded':
        0xf8a2, // [round] maps — +, add, add data, bubble, cartography
    'maps_ugc_sharp':
        0xeac3, // [sharp] maps — +, add, add data, bubble, cartography
    'margin':
        0xe3cb, // editor — adjust, adjust text, alignment, boundaries, box
    'margin_outlined':
        0xf1b1, // [outline] editor — adjust, adjust text, alignment, boundaries, box
    'margin_rounded':
        0xf8a3, // [round] editor — adjust, adjust text, alignment, boundaries, box
    'margin_sharp':
        0xeac4, // [sharp] editor — adjust, adjust text, alignment, boundaries, box
    'mark_as_unread': 0xe3cc, // action — alert, as, attention, badge, bookmark
    'mark_as_unread_outlined':
        0xf1b2, // [outline] action — alert, as, attention, badge, bookmark
    'mark_as_unread_rounded':
        0xf8a4, // [round] action — alert, as, attention, badge, bookmark
    'mark_as_unread_sharp':
        0xeac5, // [sharp] action — alert, as, attention, badge, bookmark
    'mark_chat_read':
        0xe3cd, // communication — approve, bubble, chat, chat bubble, check
    'mark_chat_read_outlined':
        0xf1b3, // [outline] communication — approve, bubble, chat, chat bubble, check
    'mark_chat_read_rounded':
        0xf8a5, // [round] communication — approve, bubble, chat, chat bubble, check
    'mark_chat_read_sharp':
        0xeac6, // [sharp] communication — approve, bubble, chat, chat bubble, check
    'mark_chat_unread':
        0xe3ce, // communication — alarm, alert, balloon, bubble, chat
    'mark_chat_unread_outlined':
        0xf1b4, // [outline] communication — alarm, alert, balloon, bubble, chat
    'mark_chat_unread_rounded':
        0xf8a6, // [round] communication — alarm, alert, balloon, bubble, chat
    'mark_chat_unread_sharp':
        0xeac7, // [sharp] communication — alarm, alert, balloon, bubble, chat
    'mark_email_read':
        0xe3cf, // communication — acknowledge, approve, archive, box, check
    'mark_email_read_outlined':
        0xf1b5, // [outline] communication — acknowledge, approve, archive, box, check
    'mark_email_read_rounded':
        0xf8a7, // [round] communication — acknowledge, approve, archive, box, check
    'mark_email_read_sharp':
        0xeac8, // [sharp] communication — acknowledge, approve, archive, box, check
    'mark_email_unread':
        0xe3d0, // communication — alert, check, circle, communication, contact
    'mark_email_unread_outlined':
        0xf1b6, // [outline] communication — alert, check, circle, communication, contact
    'mark_email_unread_rounded':
        0xf8a8, // [round] communication — alert, check, circle, communication, contact
    'mark_email_unread_sharp':
        0xeac9, // [sharp] communication — alert, check, circle, communication, contact
    'mark_unread_chat_alt':
        0xf0539, // communication — alarm, alert, bubble, bubble and dot, chat
    'mark_unread_chat_alt_outlined':
        0xf0631, // [outline] communication — alarm, alert, bubble, bubble and dot, chat
    'mark_unread_chat_alt_rounded':
        0xf0350, // [round] communication — alarm, alert, bubble, bubble and dot, chat
    'mark_unread_chat_alt_sharp':
        0xf0443, // [sharp] communication — alarm, alert, bubble, bubble and dot, chat
    'markunread':
        0xe3d1, // content — communication, contact, correspondence, diagonal lines, digital
    'markunread_mailbox':
        0xe3d2, // action — alert, box, communication, deliver, delivery
    'markunread_mailbox_outlined':
        0xf1b7, // [outline] action — alert, box, communication, deliver, delivery
    'markunread_mailbox_rounded':
        0xf8a9, // [round] action — alert, box, communication, deliver, delivery
    'markunread_mailbox_sharp':
        0xeaca, // [sharp] action — alert, box, communication, deliver, delivery
    'markunread_outlined':
        0xf1b8, // [outline] content — communication, contact, correspondence, diagonal lines, digital
    'markunread_rounded':
        0xf8aa, // [round] content — communication, contact, correspondence, diagonal lines, digital
    'markunread_sharp':
        0xeacb, // [sharp] content — communication, contact, correspondence, diagonal lines, digital
    'masks': 0xe3d3, // social — air, breath, contagion, cover, covid
    'masks_outlined':
        0xf1b9, // [outline] social — air, breath, contagion, cover, covid
    'masks_rounded':
        0xf8ab, // [round] social — air, breath, contagion, cover, covid
    'masks_sharp':
        0xeacc, // [sharp] social — air, breath, contagion, cover, covid
    'maximize': 0xe3d4, // action — arrows, box, computer, corners, design
    'maximize_outlined':
        0xf1ba, // [outline] action — arrows, box, computer, corners, design
    'maximize_rounded':
        0xf8ac, // [round] action — arrows, box, computer, corners, design
    'maximize_sharp':
        0xeacd, // [sharp] action — arrows, box, computer, corners, design
    'media_bluetooth_off':
        0xe3d5, // device — audio, bluetooth, communication, connect, connection
    'media_bluetooth_off_outlined':
        0xf1bb, // [outline] device — audio, bluetooth, communication, connect, connection
    'media_bluetooth_off_rounded':
        0xf8ad, // [round] device — audio, bluetooth, communication, connect, connection
    'media_bluetooth_off_sharp':
        0xeace, // [sharp] device — audio, bluetooth, communication, connect, connection
    'media_bluetooth_on':
        0xe3d6, // device — active, audio, bluetooth, communication, computer
    'media_bluetooth_on_outlined':
        0xf1bc, // [outline] device — active, audio, bluetooth, communication, computer
    'media_bluetooth_on_rounded':
        0xf8ae, // [round] device — active, audio, bluetooth, communication, computer
    'media_bluetooth_on_sharp':
        0xeacf, // [sharp] device — active, audio, bluetooth, communication, computer
    'mediation': 0xe3d7, // action — agreement, alliance, arrow, arrows, binding
    'mediation_outlined':
        0xf1bd, // [outline] action — agreement, alliance, arrow, arrows, binding
    'mediation_rounded':
        0xf8af, // [round] action — agreement, alliance, arrow, arrows, binding
    'mediation_sharp':
        0xead0, // [sharp] action — agreement, alliance, arrow, arrows, binding
    'medical_information': 0xf07ac, // maps — badge, card, chart, clinic, cross
    'medical_information_outlined':
        0xf06fc, // [outline] maps — badge, card, chart, clinic, cross
    'medical_information_rounded':
        0xf0804, // [round] maps — badge, card, chart, clinic, cross
    'medical_information_sharp':
        0xf0754, // [sharp] maps — badge, card, chart, clinic, cross
    'medical_services': 0xe3d8, // maps — aid, assistance, bag, briefcase, care
    'medical_services_outlined':
        0xf1be, // [outline] maps — aid, assistance, bag, briefcase, care
    'medical_services_rounded':
        0xf8b0, // [round] maps — aid, assistance, bag, briefcase, care
    'medical_services_sharp':
        0xead1, // [sharp] maps — aid, assistance, bag, briefcase, care
    'medication': 0xe3d9, // device — capsule, doctor, drug, emergency, health
    'medication_liquid':
        0xf053a, // device — +, bottle, container, cough syrup, cure
    'medication_liquid_outlined':
        0xf0632, // [outline] device — +, bottle, container, cough syrup, cure
    'medication_liquid_rounded':
        0xf0351, // [round] device — +, bottle, container, cough syrup, cure
    'medication_liquid_sharp':
        0xf0444, // [sharp] device — +, bottle, container, cough syrup, cure
    'medication_outlined':
        0xf1bf, // [outline] device — capsule, doctor, drug, emergency, health
    'medication_rounded':
        0xf8b1, // [round] device — capsule, doctor, drug, emergency, health
    'medication_sharp':
        0xead2, // [sharp] device — capsule, doctor, drug, emergency, health
    'meeting_room': 0xe3da, // places — access, arch, building, business, closed
    'meeting_room_outlined':
        0xf1c0, // [outline] places — access, arch, building, business, closed
    'meeting_room_rounded':
        0xf8b2, // [round] places — access, arch, building, business, closed
    'meeting_room_sharp':
        0xead3, // [sharp] places — access, arch, building, business, closed
    'memory': 0xe3db, // hardware — access, card, chip, circuit, computer
    'memory_outlined':
        0xf1c1, // [outline] hardware — access, card, chip, circuit, computer
    'memory_rounded':
        0xf8b3, // [round] hardware — access, card, chip, circuit, computer
    'memory_sharp':
        0xead4, // [sharp] hardware — access, card, chip, circuit, computer
    'menu': 0xe3dc, // navigation — action menu, bars, burger, collapse, drawer
    'menu_book': 0xe3dd, // maps — book, catalog, dictionary, dining, directory
    'menu_book_outlined':
        0xf1c2, // [outline] maps — book, catalog, dictionary, dining, directory
    'menu_book_rounded':
        0xf8b4, // [round] maps — book, catalog, dictionary, dining, directory
    'menu_book_sharp':
        0xead5, // [sharp] maps — book, catalog, dictionary, dining, directory
    'menu_open': 0xe3de, // navigation — arrow, back, bar menu, burger, chevron
    'menu_open_outlined':
        0xf1c3, // [outline] navigation — arrow, back, bar menu, burger, chevron
    'menu_open_rounded':
        0xf8b5, // [round] navigation — arrow, back, bar menu, burger, chevron
    'menu_open_sharp':
        0xead6, // [sharp] navigation — arrow, back, bar menu, burger, chevron
    'menu_outlined':
        0xf1c4, // [outline] navigation — action menu, bars, burger, collapse, drawer
    'menu_rounded':
        0xf8b6, // [round] navigation — action menu, bars, burger, collapse, drawer
    'menu_sharp':
        0xead7, // [sharp] navigation — action menu, bars, burger, collapse, drawer
    'merge': 0xf053b, // maps — arrow, arrows, branches, bring together, code
    'merge_outlined':
        0xf0633, // [outline] maps — arrow, arrows, branches, bring together, code
    'merge_rounded':
        0xf0352, // [round] maps — arrow, arrows, branches, bring together, code
    'merge_sharp':
        0xf0445, // [sharp] maps — arrow, arrows, branches, bring together, code
    'merge_type':
        0xe3df, // editor — arrow, arrows, branch, combine, combine branches
    'merge_type_outlined':
        0xf1c5, // [outline] editor — arrow, arrows, branch, combine, combine branches
    'merge_type_rounded':
        0xf8b7, // [round] editor — arrow, arrows, branch, combine, combine branches
    'merge_type_sharp':
        0xead8, // [sharp] editor — arrow, arrows, branch, combine, combine branches
    'message':
        0xe3e0, // communication — alert, bubble, chat, comment, communicate
    'message_outlined':
        0xf1c6, // [outline] communication — alert, bubble, chat, comment, communicate
    'message_rounded':
        0xf8b8, // [round] communication — alert, bubble, chat, comment, communicate
    'message_sharp':
        0xead9, // [sharp] communication — alert, bubble, chat, comment, communicate
    'messenger': 0xe154, // brand logo
    'messenger_outline': 0xe155,
    'messenger_outline_outlined': 0xef42,
    'messenger_outline_rounded': 0xf62f,
    'messenger_outline_sharp': 0xe850,
    'messenger_outlined': 0xef43, // [outline] brand logo
    'messenger_rounded': 0xf630, // [round] brand logo
    'messenger_sharp': 0xe851, // [sharp] brand logo
    'mic':
        0xe3e1, // av — audio, audio button, audio capture, audio input, audio recording
    'mic_external_off':
        0xe3e2, // image — audio, audio device, audio input, broken, circle
    'mic_external_off_outlined':
        0xf1c7, // [outline] image — audio, audio device, audio input, broken, circle
    'mic_external_off_rounded':
        0xf8b9, // [round] image — audio, audio device, audio input, broken, circle
    'mic_external_off_sharp':
        0xeada, // [sharp] image — audio, audio device, audio input, broken, circle
    'mic_external_on':
        0xe3e3, // image — active, audio, broadcast, circle, communication
    'mic_external_on_outlined':
        0xf1c8, // [outline] image — active, audio, broadcast, circle, communication
    'mic_external_on_rounded':
        0xf8ba, // [round] image — active, audio, broadcast, circle, communication
    'mic_external_on_sharp':
        0xeadb, // [sharp] image — active, audio, broadcast, circle, communication
    'mic_none':
        0xe3e4, // av — audio, audio button, audio capture, audio input, audio recording
    'mic_none_outlined':
        0xf1c9, // [outline] av — audio, audio button, audio capture, audio input, audio recording
    'mic_none_rounded':
        0xf8bb, // [round] av — audio, audio button, audio capture, audio input, audio recording
    'mic_none_sharp':
        0xeadc, // [sharp] av — audio, audio button, audio capture, audio input, audio recording
    'mic_off':
        0xe3e5, // av — audio, audio input disabled, audio off, audio settings, bar
    'mic_off_outlined':
        0xf1ca, // [outline] av — audio, audio input disabled, audio off, audio settings, bar
    'mic_off_rounded':
        0xf8bc, // [round] av — audio, audio input disabled, audio off, audio settings, bar
    'mic_off_sharp':
        0xeadd, // [sharp] av — audio, audio input disabled, audio off, audio settings, bar
    'mic_outlined':
        0xf1cb, // [outline] av — audio, audio button, audio capture, audio input, audio recording
    'mic_rounded':
        0xf8bd, // [round] av — audio, audio button, audio capture, audio input, audio recording
    'mic_sharp':
        0xeade, // [sharp] av — audio, audio button, audio capture, audio input, audio recording
    'microwave':
        0xe3e6, // places — appliance, convenience, cook, cooking, defrost
    'microwave_outlined':
        0xf1cc, // [outline] places — appliance, convenience, cook, cooking, defrost
    'microwave_rounded':
        0xf8be, // [round] places — appliance, convenience, cook, cooking, defrost
    'microwave_sharp':
        0xeadf, // [sharp] places — appliance, convenience, cook, cooking, defrost
    'military_tech':
        0xe3e7, // social — accomplishment, achievement, air force, army, award
    'military_tech_outlined':
        0xf1cd, // [outline] social — accomplishment, achievement, air force, army, award
    'military_tech_rounded':
        0xf8bf, // [round] social — accomplishment, achievement, air force, army, award
    'military_tech_sharp':
        0xeae0, // [sharp] social — accomplishment, achievement, air force, army, award
    'minimize': 0xe3e8, // action — bar, bottom, close, collapse, compact
    'minimize_outlined':
        0xf1ce, // [outline] action — bar, bottom, close, collapse, compact
    'minimize_rounded':
        0xf8c0, // [round] action — bar, bottom, close, collapse, compact
    'minimize_sharp':
        0xeae1, // [sharp] action — bar, bottom, close, collapse, compact
    'minor_crash':
        0xf07ad, // maps — accident, alert, attention, auto, automobile
    'minor_crash_outlined':
        0xf06fd, // [outline] maps — accident, alert, attention, auto, automobile
    'minor_crash_rounded':
        0xf0805, // [round] maps — accident, alert, attention, auto, automobile
    'minor_crash_sharp':
        0xf0755, // [sharp] maps — accident, alert, attention, auto, automobile
    'miscellaneous_services': 0xe3e9, // maps
    'miscellaneous_services_outlined': 0xf1cf, // [outline] maps
    'miscellaneous_services_rounded': 0xf8c1, // [round] maps
    'miscellaneous_services_sharp': 0xeae2, // [sharp] maps
    'missed_video_call': 0xe3ea, // av — absent, alert, arrow, call, camera
    'missed_video_call_outlined':
        0xf1d0, // [outline] av — absent, alert, arrow, call, camera
    'missed_video_call_rounded':
        0xf8c2, // [round] av — absent, alert, arrow, call, camera
    'missed_video_call_sharp':
        0xeae3, // [sharp] av — absent, alert, arrow, call, camera
    'mms':
        0xe3eb, // notification — attachment, bubble, chat, comment, communicate
    'mms_outlined':
        0xf1d1, // [outline] notification — attachment, bubble, chat, comment, communicate
    'mms_rounded':
        0xf8c3, // [round] notification — attachment, bubble, chat, comment, communicate
    'mms_sharp':
        0xeae4, // [sharp] notification — attachment, bubble, chat, comment, communicate
    'mobile_friendly': 0xe3ec, // device — Android, OS, approve, approved, cell
    'mobile_friendly_outlined':
        0xf1d2, // [outline] device — Android, OS, approve, approved, cell
    'mobile_friendly_rounded':
        0xf8c4, // [round] device — Android, OS, approve, approved, cell
    'mobile_friendly_sharp':
        0xeae5, // [sharp] device — Android, OS, approve, approved, cell
    'mobile_off': 0xe3ed, // device — Android, OS, access, airplane mode, barred
    'mobile_off_outlined':
        0xf1d3, // [outline] device — Android, OS, access, airplane mode, barred
    'mobile_off_rounded':
        0xf8c5, // [round] device — Android, OS, access, airplane mode, barred
    'mobile_off_sharp':
        0xeae6, // [sharp] device — Android, OS, access, airplane mode, barred
    'mobile_screen_share':
        0xe3ee, // communication — Android, OS, access, broadcast, cast
    'mobile_screen_share_outlined':
        0xf1d4, // [outline] communication — Android, OS, access, broadcast, cast
    'mobile_screen_share_rounded':
        0xf8c6, // [round] communication — Android, OS, access, broadcast, cast
    'mobile_screen_share_sharp':
        0xeae7, // [sharp] communication — Android, OS, access, broadcast, cast
    'mobiledata_off':
        0xe3ef, // device — arrow, cellular, cellular data off, cellular network off, connection lost
    'mobiledata_off_outlined':
        0xf1d5, // [outline] device — arrow, cellular, cellular data off, cellular network off, connection lost
    'mobiledata_off_rounded':
        0xf8c7, // [round] device — arrow, cellular, cellular data off, cellular network off, connection lost
    'mobiledata_off_sharp':
        0xeae8, // [sharp] device — arrow, cellular, cellular data off, cellular network off, connection lost
    'mode': 0xe3f0, // editor — alter, author, change, compose, create
    'mode_comment':
        0xe3f1, // editor — balloon, bubble, cartoon, chat, chat bubble
    'mode_comment_outlined':
        0xf1d6, // [outline] editor — balloon, bubble, cartoon, chat, chat bubble
    'mode_comment_rounded':
        0xf8c8, // [round] editor — balloon, bubble, cartoon, chat, chat bubble
    'mode_comment_sharp':
        0xeae9, // [sharp] editor — balloon, bubble, cartoon, chat, chat bubble
    'mode_edit': 0xe3f2, // editor — alter, author, change, compose, create
    'mode_edit_outline':
        0xe3f3, // editor — alter, author, change, compose, create
    'mode_edit_outline_outlined':
        0xf1d7, // [outline] editor — alter, author, change, compose, create
    'mode_edit_outline_rounded':
        0xf8c9, // [round] editor — alter, author, change, compose, create
    'mode_edit_outline_sharp':
        0xeaea, // [sharp] editor — alter, author, change, compose, create
    'mode_edit_outlined':
        0xf1d8, // [outline] editor — alter, author, change, compose, create
    'mode_edit_rounded':
        0xf8ca, // [round] editor — alter, author, change, compose, create
    'mode_edit_sharp':
        0xeaeb, // [sharp] editor — alter, author, change, compose, create
    'mode_fan_off':
        0xf07ae, // home — air, air conditioner, angular, appliance, blades
    'mode_fan_off_outlined':
        0xf06fe, // [outline] home — air, air conditioner, angular, appliance, blades
    'mode_fan_off_rounded':
        0xf0806, // [round] home — air, air conditioner, angular, appliance, blades
    'mode_fan_off_sharp':
        0xf0756, // [sharp] home — air, air conditioner, angular, appliance, blades
    'mode_night':
        0xe3f4, // device — adjust, adjustment, brightness, contrast, crescent
    'mode_night_outlined':
        0xf1d9, // [outline] device — adjust, adjustment, brightness, contrast, crescent
    'mode_night_rounded':
        0xf8cb, // [round] device — adjust, adjustment, brightness, contrast, crescent
    'mode_night_sharp':
        0xeaec, // [sharp] device — adjust, adjustment, brightness, contrast, crescent
    'mode_of_travel': 0xf053c, // maps — adventure, air, arrow, bicycle, choice
    'mode_of_travel_outlined':
        0xf0634, // [outline] maps — adventure, air, arrow, bicycle, choice
    'mode_of_travel_rounded':
        0xf0353, // [round] maps — adventure, air, arrow, bicycle, choice
    'mode_of_travel_sharp':
        0xf0446, // [sharp] maps — adventure, air, arrow, bicycle, choice
    'mode_outlined':
        0xf1da, // [outline] editor — alter, author, change, compose, create
    'mode_rounded':
        0xf8cc, // [round] editor — alter, author, change, compose, create
    'mode_sharp':
        0xeaed, // [sharp] editor — alter, author, change, compose, create
    'mode_standby':
        0xe3f5, // device — control element, device, disturb, electronics, energy saver
    'mode_standby_outlined':
        0xf1db, // [outline] device — control element, device, disturb, electronics, energy saver
    'mode_standby_rounded':
        0xf8cd, // [round] device — control element, device, disturb, electronics, energy saver
    'mode_standby_sharp':
        0xeaee, // [sharp] device — control element, device, disturb, electronics, energy saver
    'model_training': 0xe3f6, // action — ai, algorithm, analysis, arrow, brain
    'model_training_outlined':
        0xf1dc, // [outline] action — ai, algorithm, analysis, arrow, brain
    'model_training_rounded':
        0xf8ce, // [round] action — ai, algorithm, analysis, arrow, brain
    'model_training_sharp':
        0xeaef, // [sharp] action — ai, algorithm, analysis, arrow, brain
    'monetization_on':
        0xe3f7, // editor — activate, active, arrows, beginning, bill
    'monetization_on_outlined':
        0xf1dd, // [outline] editor — activate, active, arrows, beginning, bill
    'monetization_on_rounded':
        0xf8cf, // [round] editor — activate, active, arrows, beginning, bill
    'monetization_on_sharp':
        0xeaf0, // [sharp] editor — activate, active, arrows, beginning, bill
    'money': 0xe3f8, // maps — 100, accounting, banking, bill, budget
    'money_off': 0xe3f9, // editor — bill, blocked, card, cart, cash
    'money_off_csred': 0xe3fa, // editor — bill, blocked, card, cart, cash
    'money_off_csred_outlined':
        0xf1de, // [outline] editor — bill, blocked, card, cart, cash
    'money_off_csred_rounded':
        0xf8d0, // [round] editor — bill, blocked, card, cart, cash
    'money_off_csred_sharp':
        0xeaf1, // [sharp] editor — bill, blocked, card, cart, cash
    'money_off_outlined':
        0xf1df, // [outline] editor — bill, blocked, card, cart, cash
    'money_off_rounded':
        0xf8d1, // [round] editor — bill, blocked, card, cart, cash
    'money_off_sharp':
        0xeaf2, // [sharp] editor — bill, blocked, card, cart, cash
    'money_outlined':
        0xf1e0, // [outline] maps — 100, accounting, banking, bill, budget
    'money_rounded':
        0xf8d2, // [round] maps — 100, accounting, banking, bill, budget
    'money_sharp':
        0xeaf3, // [sharp] maps — 100, accounting, banking, bill, budget
    'monitor': 0xe3fb, // hardware — Android, OS, base, chrome, communication
    'monitor_heart':
        0xf053d, // device — baseline, cardiogram, care, computer, device
    'monitor_heart_outlined':
        0xf0635, // [outline] device — baseline, cardiogram, care, computer, device
    'monitor_heart_rounded':
        0xf0354, // [round] device — baseline, cardiogram, care, computer, device
    'monitor_heart_sharp':
        0xf0447, // [sharp] device — baseline, cardiogram, care, computer, device
    'monitor_outlined':
        0xf1e1, // [outline] hardware — Android, OS, base, chrome, communication
    'monitor_rounded':
        0xf8d3, // [round] hardware — Android, OS, base, chrome, communication
    'monitor_sharp':
        0xeaf4, // [sharp] hardware — Android, OS, base, chrome, communication
    'monitor_weight':
        0xe3fc, // device — accuracy, analysis, balance, body, body composition
    'monitor_weight_outlined':
        0xf1e2, // [outline] device — accuracy, analysis, balance, body, body composition
    'monitor_weight_rounded':
        0xf8d4, // [round] device — accuracy, analysis, balance, body, body composition
    'monitor_weight_sharp':
        0xeaf5, // [sharp] device — accuracy, analysis, balance, body, body composition
    'monochrome_photos':
        0xe3fd, // image — album, black, black and white, camera, digital media
    'monochrome_photos_outlined':
        0xf1e3, // [outline] image — album, black, black and white, camera, digital media
    'monochrome_photos_rounded':
        0xf8d5, // [round] image — album, black, black and white, camera, digital media
    'monochrome_photos_sharp':
        0xeaf6, // [sharp] image — album, black, black and white, camera, digital media
    'mood': 0xe3fe, // social — add, character, chat, cheerful, circle
    'mood_bad':
        0xe3ff, // social — avatar, bad, circle, circular, disappointment
    'mood_bad_outlined':
        0xf1e4, // [outline] social — avatar, bad, circle, circular, disappointment
    'mood_bad_rounded':
        0xf8d6, // [round] social — avatar, bad, circle, circular, disappointment
    'mood_bad_sharp':
        0xeaf7, // [sharp] social — avatar, bad, circle, circular, disappointment
    'mood_outlined':
        0xf1e5, // [outline] social — add, character, chat, cheerful, circle
    'mood_rounded':
        0xf8d7, // [round] social — add, character, chat, cheerful, circle
    'mood_sharp':
        0xeaf8, // [sharp] social — add, character, chat, cheerful, circle
    'moped': 0xe400, // maps — automobile, bike, buy, car, cars
    'moped_outlined':
        0xf1e6, // [outline] maps — automobile, bike, buy, car, cars
    'moped_rounded': 0xf8d8, // [round] maps — automobile, bike, buy, car, cars
    'moped_sharp': 0xeaf9, // [sharp] maps — automobile, bike, buy, car, cars
    'more': 0xe401, // notification — 3, additional, archive, bookmark, circle
    'more_horiz':
        0xe402, // navigation — 3, additional, bar menu, choices, content menu
    'more_horiz_outlined':
        0xf1e7, // [outline] navigation — 3, additional, bar menu, choices, content menu
    'more_horiz_rounded':
        0xf8d9, // [round] navigation — 3, additional, bar menu, choices, content menu
    'more_horiz_sharp':
        0xeafa, // [sharp] navigation — 3, additional, bar menu, choices, content menu
    'more_outlined':
        0xf1e8, // [outline] notification — 3, additional, archive, bookmark, circle
    'more_rounded':
        0xf8da, // [round] notification — 3, additional, archive, bookmark, circle
    'more_sharp':
        0xeafb, // [sharp] notification — 3, additional, archive, bookmark, circle
    'more_time': 0xe403, // communication — +, add, add time, alarm, appointment
    'more_time_outlined':
        0xf1e9, // [outline] communication — +, add, add time, alarm, appointment
    'more_time_rounded':
        0xf8db, // [round] communication — +, add, add time, alarm, appointment
    'more_time_sharp':
        0xeafc, // [sharp] communication — +, add, add time, alarm, appointment
    'more_vert':
        0xe404, // navigation — 3, additional options, android, context menu, detail menu
    'more_vert_outlined':
        0xf1ea, // [outline] navigation — 3, additional options, android, context menu, detail menu
    'more_vert_rounded':
        0xf8dc, // [round] navigation — 3, additional options, android, context menu, detail menu
    'more_vert_sharp':
        0xeafd, // [sharp] navigation — 3, additional options, android, context menu, detail menu
    'mosque': 0xf053e, // maps — architecture, building, dome, faith, holy place
    'mosque_outlined':
        0xf0636, // [outline] maps — architecture, building, dome, faith, holy place
    'mosque_rounded':
        0xf0355, // [round] maps — architecture, building, dome, faith, holy place
    'mosque_sharp':
        0xf0448, // [sharp] maps — architecture, building, dome, faith, holy place
    'motion_photos_auto':
        0xe405, // image — A, advanced photo, alphabet, animation, auto
    'motion_photos_auto_outlined':
        0xf1eb, // [outline] image — A, advanced photo, alphabet, animation, auto
    'motion_photos_auto_rounded':
        0xf8dd, // [round] image — A, advanced photo, alphabet, animation, auto
    'motion_photos_auto_sharp':
        0xeafe, // [sharp] image — A, advanced photo, alphabet, animation, auto
    'motion_photos_off':
        0xe406, // image — animated, animation, block, camera, cancel
    'motion_photos_off_outlined':
        0xf1ec, // [outline] image — animated, animation, block, camera, cancel
    'motion_photos_off_rounded':
        0xf8de, // [round] image — animated, animation, block, camera, cancel
    'motion_photos_off_sharp':
        0xeaff, // [sharp] image — animated, animation, block, camera, cancel
    'motion_photos_on':
        0xe407, // image — active, animation, camera, capture, circle
    'motion_photos_on_outlined':
        0xf1ed, // [outline] image — active, animation, camera, capture, circle
    'motion_photos_on_rounded':
        0xf8df, // [round] image — active, animation, camera, capture, circle
    'motion_photos_on_sharp':
        0xeb00, // [sharp] image — active, animation, camera, capture, circle
    'motion_photos_pause':
        0xe408, // image — animation, camera, capture, circle, frame
    'motion_photos_pause_outlined':
        0xf1ee, // [outline] image — animation, camera, capture, circle, frame
    'motion_photos_pause_rounded':
        0xf8e0, // [round] image — animation, camera, capture, circle, frame
    'motion_photos_pause_sharp':
        0xeb01, // [sharp] image — animation, camera, capture, circle, frame
    'motion_photos_paused':
        0xe409, // image — animation, camera, capture, circle, frame
    'motion_photos_paused_outlined':
        0xf1ef, // [outline] image — animation, camera, capture, circle, frame
    'motion_photos_paused_rounded':
        0xf8e1, // [round] image — animation, camera, capture, circle, frame
    'motion_photos_paused_sharp':
        0xeb02, // [sharp] image — animation, camera, capture, circle, frame
    'motorcycle':
        0xe40a, // Transit — adventure, automobile, bicycle, bike, biking
    'motorcycle_outlined':
        0xf1f0, // [outline] Transit — adventure, automobile, bicycle, bike, biking
    'motorcycle_rounded':
        0xf8e2, // [round] Transit — adventure, automobile, bicycle, bike, biking
    'motorcycle_sharp':
        0xeb03, // [sharp] Transit — adventure, automobile, bicycle, bike, biking
    'mouse': 0xe40b, // hardware — click, computer, computing, cursor, desktop
    'mouse_outlined':
        0xf1f1, // [outline] hardware — click, computer, computing, cursor, desktop
    'mouse_rounded':
        0xf8e3, // [round] hardware — click, computer, computing, cursor, desktop
    'mouse_sharp':
        0xeb04, // [sharp] hardware — click, computer, computing, cursor, desktop
    'move_down':
        0xf053f, // editor — arrow, arrow down, arrow head, command, direction
    'move_down_outlined':
        0xf0637, // [outline] editor — arrow, arrow down, arrow head, command, direction
    'move_down_rounded':
        0xf0356, // [round] editor — arrow, arrow down, arrow head, command, direction
    'move_down_sharp':
        0xf0449, // [sharp] editor — arrow, arrow down, arrow head, command, direction
    'move_to_inbox':
        0xe40c, // content — archive, arrow, box, communication, container
    'move_to_inbox_outlined':
        0xf1f2, // [outline] content — archive, arrow, box, communication, container
    'move_to_inbox_rounded':
        0xf8e4, // [round] content — archive, arrow, box, communication, container
    'move_to_inbox_sharp':
        0xeb05, // [sharp] content — archive, arrow, box, communication, container
    'move_up':
        0xf0540, // editor — arrow, arrow head, ascend, direction, elevate
    'move_up_outlined':
        0xf0638, // [outline] editor — arrow, arrow head, ascend, direction, elevate
    'move_up_rounded':
        0xf0357, // [round] editor — arrow, arrow head, ascend, direction, elevate
    'move_up_sharp':
        0xf044a, // [sharp] editor — arrow, arrow head, ascend, direction, elevate
    'movie': 0xe40d, // av — camera, cinema, clapper, clapperboard, clip
    'movie_creation':
        0xe40e, // image — camera, cinema, clapper, clapperboard, clip
    'movie_creation_outlined':
        0xf1f3, // [outline] image — camera, cinema, clapper, clapperboard, clip
    'movie_creation_rounded':
        0xf8e5, // [round] image — camera, cinema, clapper, clapperboard, clip
    'movie_creation_sharp':
        0xeb06, // [sharp] image — camera, cinema, clapper, clapperboard, clip
    'movie_edit': 0xf08b9, // av — analog, camcorder, camera, cinema, circle
    'movie_filter':
        0xe40f, // image — adjust, adjust video, ai, artificial, automatic
    'movie_filter_outlined':
        0xf1f4, // [outline] image — adjust, adjust video, ai, artificial, automatic
    'movie_filter_rounded':
        0xf8e6, // [round] image — adjust, adjust video, ai, artificial, automatic
    'movie_filter_sharp':
        0xeb07, // [sharp] image — adjust, adjust video, ai, artificial, automatic
    'movie_outlined':
        0xf1f5, // [outline] av — camera, cinema, clapper, clapperboard, clip
    'movie_rounded':
        0xf8e7, // [round] av — camera, cinema, clapper, clapperboard, clip
    'movie_sharp':
        0xeb08, // [sharp] av — camera, cinema, clapper, clapperboard, clip
    'moving': 0xe410, // maps — active, activity, advancing, alive, animate
    'moving_outlined':
        0xf1f6, // [outline] maps — active, activity, advancing, alive, animate
    'moving_rounded':
        0xf8e8, // [round] maps — active, activity, advancing, alive, animate
    'moving_sharp':
        0xeb09, // [sharp] maps — active, activity, advancing, alive, animate
    'mp':
        0xe411, // image — adjustment, alphabet, audio, audio output, character
    'mp_outlined':
        0xf1f7, // [outline] image — adjustment, alphabet, audio, audio output, character
    'mp_rounded':
        0xf8e9, // [round] image — adjustment, alphabet, audio, audio output, character
    'mp_sharp':
        0xeb0a, // [sharp] image — adjustment, alphabet, audio, audio output, character
    'multiline_chart': 0xe412, // editor — analysis, analytics, axis, bar, bars
    'multiline_chart_outlined':
        0xf1f8, // [outline] editor — analysis, analytics, axis, bar, bars
    'multiline_chart_rounded':
        0xf8ea, // [round] editor — analysis, analytics, axis, bar, bars
    'multiline_chart_sharp':
        0xeb0b, // [sharp] editor — analysis, analytics, axis, bar, bars
    'multiple_stop': 0xe413, // maps — arrows, audio, complete, dash, dashed
    'multiple_stop_outlined':
        0xf1f9, // [outline] maps — arrows, audio, complete, dash, dashed
    'multiple_stop_rounded':
        0xf8eb, // [round] maps — arrows, audio, complete, dash, dashed
    'multiple_stop_sharp':
        0xeb0c, // [sharp] maps — arrows, audio, complete, dash, dashed
    'multitrack_audio':
        0xe2e3, // device — audio, audio analysis, audio control, audio customization, audio effect
    'multitrack_audio_outlined':
        0xf0d0, // [outline] device — audio, audio analysis, audio control, audio customization, audio effect
    'multitrack_audio_rounded':
        0xf7bd, // [round] device — audio, audio analysis, audio control, audio customization, audio effect
    'multitrack_audio_sharp':
        0xe9de, // [sharp] device — audio, audio analysis, audio control, audio customization, audio effect
    'museum': 0xe414, // maps — ancient, architecture, art, artifact, attraction
    'museum_outlined':
        0xf1fa, // [outline] maps — ancient, architecture, art, artifact, attraction
    'museum_rounded':
        0xf8ec, // [round] maps — ancient, architecture, art, artifact, attraction
    'museum_sharp':
        0xeb0d, // [sharp] maps — ancient, architecture, art, artifact, attraction
    'music_note':
        0xe415, // image — audio, audio file, audiotrack, clef, composition
    'music_note_outlined':
        0xf1fb, // [outline] image — audio, audio file, audiotrack, clef, composition
    'music_note_rounded':
        0xf8ed, // [round] image — audio, audio file, audiotrack, clef, composition
    'music_note_sharp':
        0xeb0e, // [sharp] image — audio, audio file, audiotrack, clef, composition
    'music_off':
        0xe416, // image — audio, audio off, audiotrack, block, blocked music
    'music_off_outlined':
        0xf1fc, // [outline] image — audio, audio off, audiotrack, block, blocked music
    'music_off_rounded':
        0xf8ee, // [round] image — audio, audio off, audiotrack, block, blocked music
    'music_off_sharp':
        0xeb0f, // [sharp] image — audio, audio off, audiotrack, block, blocked music
    'music_video': 0xe417, // av — band, broadcast, camera, cinema, clip
    'music_video_outlined':
        0xf1fd, // [outline] av — band, broadcast, camera, cinema, clip
    'music_video_rounded':
        0xf8ef, // [round] av — band, broadcast, camera, cinema, clip
    'music_video_sharp':
        0xeb10, // [sharp] av — band, broadcast, camera, cinema, clip
    'my_library_add': 0xe375, // av — +, add, archive, book, catalog
    'my_library_add_outlined':
        0xf15f, // [outline] av — +, add, archive, book, catalog
    'my_library_add_rounded':
        0xf84f, // [round] av — +, add, archive, book, catalog
    'my_library_add_sharp':
        0xea70, // [sharp] av — +, add, archive, book, catalog
    'my_library_books': 0xe377, // av — academy, add, album, archives, audio
    'my_library_books_outlined':
        0xf160, // [outline] av — academy, add, album, archives, audio
    'my_library_books_rounded':
        0xf850, // [round] av — academy, add, album, archives, audio
    'my_library_books_sharp':
        0xea71, // [sharp] av — academy, add, album, archives, audio
    'my_library_music':
        0xe378, // av — add, album, archive, audio, audio collection
    'my_library_music_outlined':
        0xf161, // [outline] av — add, album, archive, audio, audio collection
    'my_library_music_rounded':
        0xf851, // [round] av — add, album, archive, audio, audio collection
    'my_library_music_sharp':
        0xea72, // [sharp] av — add, album, archive, audio, audio collection
    'my_location':
        0xe418, // maps — area, center location, circle, compass, coordinates
    'my_location_outlined':
        0xf1fe, // [outline] maps — area, center location, circle, compass, coordinates
    'my_location_rounded':
        0xf8f0, // [round] maps — area, center location, circle, compass, coordinates
    'my_location_sharp':
        0xeb11, // [sharp] maps — area, center location, circle, compass, coordinates
    'nat':
        0xe419, // communication — atlas, boundaries, cartography, circle, circular
    'nat_outlined':
        0xf1ff, // [outline] communication — atlas, boundaries, cartography, circle, circular
    'nat_rounded':
        0xf8f1, // [round] communication — atlas, boundaries, cartography, circle, circular
    'nat_sharp':
        0xeb12, // [sharp] communication — atlas, boundaries, cartography, circle, circular
    'nature': 0xe41a, // image — biology, bloom, botanical, botany, branch
    'nature_outlined':
        0xf200, // [outline] image — biology, bloom, botanical, botany, branch
    'nature_people':
        0xe41b, // image — activity, adventure, body, camping, community
    'nature_people_outlined':
        0xf201, // [outline] image — activity, adventure, body, camping, community
    'nature_people_rounded':
        0xf8f2, // [round] image — activity, adventure, body, camping, community
    'nature_people_sharp':
        0xeb13, // [sharp] image — activity, adventure, body, camping, community
    'nature_rounded':
        0xf8f3, // [round] image — biology, bloom, botanical, botany, branch
    'nature_sharp':
        0xeb14, // [sharp] image — biology, bloom, botanical, botany, branch
    'navigate_before': 0xe41c, // image — angle, arrow, arrows, back, backward
    'navigate_before_outlined':
        0xf202, // [outline] image — angle, arrow, arrows, back, backward
    'navigate_before_rounded':
        0xf8f4, // [round] image — angle, arrow, arrows, back, backward
    'navigate_before_sharp':
        0xeb15, // [sharp] image — angle, arrow, arrows, back, backward
    'navigate_next': 0xe41d, // image — advance, angle, arrow, arrows, bracket
    'navigate_next_outlined':
        0xf203, // [outline] image — advance, angle, arrow, arrows, bracket
    'navigate_next_rounded':
        0xf8f5, // [round] image — advance, angle, arrow, arrows, bracket
    'navigate_next_sharp':
        0xeb16, // [sharp] image — advance, angle, arrow, arrows, bracket
    'navigation':
        0xe41e, // maps — arrow, compass, course, destination, direction
    'navigation_outlined':
        0xf204, // [outline] maps — arrow, compass, course, destination, direction
    'navigation_rounded':
        0xf8f6, // [round] maps — arrow, compass, course, destination, direction
    'navigation_sharp':
        0xeb17, // [sharp] maps — arrow, compass, course, destination, direction
    'near_me':
        0xe41f, // maps — area, arrow, compass, current location, destination
    'near_me_disabled':
        0xe420, // maps — blocked, compass blocked, compass disabled, compass off, destination
    'near_me_disabled_outlined':
        0xf205, // [outline] maps — blocked, compass blocked, compass disabled, compass off, destination
    'near_me_disabled_rounded':
        0xf8f7, // [round] maps — blocked, compass blocked, compass disabled, compass off, destination
    'near_me_disabled_sharp':
        0xeb18, // [sharp] maps — blocked, compass blocked, compass disabled, compass off, destination
    'near_me_outlined':
        0xf206, // [outline] maps — area, arrow, compass, current location, destination
    'near_me_rounded':
        0xf8f8, // [round] maps — area, arrow, compass, current location, destination
    'near_me_sharp':
        0xeb19, // [sharp] maps — area, arrow, compass, current location, destination
    'nearby_error':
        0xe421, // device — !, alert, attention, caution, communication
    'nearby_error_outlined':
        0xf207, // [outline] device — !, alert, attention, caution, communication
    'nearby_error_rounded':
        0xf8f9, // [round] device — !, alert, attention, caution, communication
    'nearby_error_sharp':
        0xeb1a, // [sharp] device — !, alert, attention, caution, communication
    'nearby_off':
        0xe422, // device — area, circle, close, connected off, connection
    'nearby_off_outlined':
        0xf208, // [outline] device — area, circle, close, connected off, connection
    'nearby_off_rounded':
        0xf8fa, // [round] device — area, circle, close, connected off, connection
    'nearby_off_sharp':
        0xeb1b, // [sharp] device — area, circle, close, connected off, connection
    'nest_cam_wired_stand':
        0xf07af, // home — bedroom, camera, camera on stand, cctv, device
    'nest_cam_wired_stand_outlined':
        0xf06ff, // [outline] home — bedroom, camera, camera on stand, cctv, device
    'nest_cam_wired_stand_rounded':
        0xf0807, // [round] home — bedroom, camera, camera on stand, cctv, device
    'nest_cam_wired_stand_sharp':
        0xf0757, // [sharp] home — bedroom, camera, camera on stand, cctv, device
    'network_cell':
        0xe423, // device — bars, cell, cellular, communications, connection
    'network_cell_outlined':
        0xf209, // [outline] device — bars, cell, cellular, communications, connection
    'network_cell_rounded':
        0xf8fb, // [round] device — bars, cell, cellular, communications, connection
    'network_cell_sharp':
        0xeb1c, // [sharp] device — bars, cell, cellular, communications, connection
    'network_check':
        0xe424, // notification — check, confirmed, connect, connected, connection
    'network_check_outlined':
        0xf20a, // [outline] notification — check, confirmed, connect, connected, connection
    'network_check_rounded':
        0xf8fc, // [round] notification — check, confirmed, connect, connected, connection
    'network_check_sharp':
        0xeb1d, // [sharp] notification — check, confirmed, connect, connected, connection
    'network_locked':
        0xe425, // notification — access, alert, available, cellular, chain
    'network_locked_outlined':
        0xf20b, // [outline] notification — access, alert, available, cellular, chain
    'network_locked_rounded':
        0xf8fd, // [round] notification — access, alert, available, cellular, chain
    'network_locked_sharp':
        0xeb1e, // [sharp] notification — access, alert, available, cellular, chain
    'network_ping':
        0xf06bf, // action — alert, antenna, available, bars, cellular
    'network_ping_outlined':
        0xf06a5, // [outline] action — alert, antenna, available, bars, cellular
    'network_ping_rounded':
        0xf06cc, // [round] action — alert, antenna, available, bars, cellular
    'network_ping_sharp':
        0xf06b2, // [sharp] action — alert, antenna, available, bars, cellular
    'network_wifi': 0xe426, // device — access, antenna, arcs, available, bars
    'network_wifi_1_bar':
        0xf07b0, // device — access point, antenna, bar, cell, cellular
    'network_wifi_1_bar_outlined':
        0xf0700, // [outline] device — access point, antenna, bar, cell, cellular
    'network_wifi_1_bar_rounded':
        0xf0808, // [round] device — access point, antenna, bar, cell, cellular
    'network_wifi_1_bar_sharp':
        0xf0758, // [sharp] device — access point, antenna, bar, cell, cellular
    'network_wifi_2_bar':
        0xf07b1, // device — access point, antenna, arc, bars, broadcast
    'network_wifi_2_bar_outlined':
        0xf0701, // [outline] device — access point, antenna, arc, bars, broadcast
    'network_wifi_2_bar_rounded':
        0xf0809, // [round] device — access point, antenna, arc, bars, broadcast
    'network_wifi_2_bar_sharp':
        0xf0759, // [sharp] device — access point, antenna, arc, bars, broadcast
    'network_wifi_3_bar': 0xf07b2, // device — access, antenna, arc, bars, cell
    'network_wifi_3_bar_outlined':
        0xf0702, // [outline] device — access, antenna, arc, bars, cell
    'network_wifi_3_bar_rounded':
        0xf080a, // [round] device — access, antenna, arc, bars, cell
    'network_wifi_3_bar_sharp':
        0xf075a, // [sharp] device — access, antenna, arc, bars, cell
    'network_wifi_outlined':
        0xf20c, // [outline] device — access, antenna, arcs, available, bars
    'network_wifi_rounded':
        0xf8fe, // [round] device — access, antenna, arcs, available, bars
    'network_wifi_sharp':
        0xeb1f, // [sharp] device — access, antenna, arcs, available, bars
    'new_label': 0xe427, // action — +, add, archive, badge, banner
    'new_label_outlined':
        0xf20d, // [outline] action — +, add, archive, badge, banner
    'new_label_rounded':
        0xf8ff, // [round] action — +, add, archive, badge, banner
    'new_label_sharp':
        0xeb20, // [sharp] action — +, add, archive, badge, banner
    'new_releases':
        0xe428, // av — accepted, accreditation, approval, approve, authentic
    'new_releases_outlined':
        0xf20e, // [outline] av — accepted, accreditation, approval, approve, authentic
    'new_releases_rounded':
        0xf0000, // [round] av — accepted, accreditation, approval, approve, authentic
    'new_releases_sharp':
        0xeb21, // [sharp] av — accepted, accreditation, approval, approve, authentic
    'newspaper':
        0xf0541, // file — article, book, communication, current events, daily
    'newspaper_outlined':
        0xf0639, // [outline] file — article, book, communication, current events, daily
    'newspaper_rounded':
        0xf0358, // [round] file — article, book, communication, current events, daily
    'newspaper_sharp':
        0xf044b, // [sharp] file — article, book, communication, current events, daily
    'next_plan':
        0xe429, // action — agenda, arrow, blueprint, business, calendar
    'next_plan_outlined':
        0xf20f, // [outline] action — agenda, arrow, blueprint, business, calendar
    'next_plan_rounded':
        0xf0001, // [round] action — agenda, arrow, blueprint, business, calendar
    'next_plan_sharp':
        0xeb22, // [sharp] action — agenda, arrow, blueprint, business, calendar
    'next_week': 0xe42a, // content — agenda, appointment, arrow, bag, baggage
    'next_week_outlined':
        0xf210, // [outline] content — agenda, appointment, arrow, bag, baggage
    'next_week_rounded':
        0xf0002, // [round] content — agenda, appointment, arrow, bag, baggage
    'next_week_sharp':
        0xeb23, // [sharp] content — agenda, appointment, arrow, bag, baggage
    'nfc':
        0xe42b, // device — access, communication, connect, contactless, device
    'nfc_outlined':
        0xf211, // [outline] device — access, communication, connect, contactless, device
    'nfc_rounded':
        0xf0003, // [round] device — access, communication, connect, contactless, device
    'nfc_sharp':
        0xeb24, // [sharp] device — access, communication, connect, contactless, device
    'night_shelter':
        0xe42c, // places — abode, accommodation, architecture, assistance, bed
    'night_shelter_outlined':
        0xf212, // [outline] places — abode, accommodation, architecture, assistance, bed
    'night_shelter_rounded':
        0xf0004, // [round] places — abode, accommodation, architecture, assistance, bed
    'night_shelter_sharp':
        0xeb25, // [sharp] places — abode, accommodation, architecture, assistance, bed
    'nightlife': 0xe42d, // maps — activity, alcohol, bar, beer, beverage
    'nightlife_outlined':
        0xf213, // [outline] maps — activity, alcohol, bar, beer, beverage
    'nightlife_rounded':
        0xf0005, // [round] maps — activity, alcohol, bar, beer, beverage
    'nightlife_sharp':
        0xeb26, // [sharp] maps — activity, alcohol, bar, beer, beverage
    'nightlight':
        0xe42e, // device — astronomy, bedtime, brightness, celestial, circle
    'nightlight_outlined':
        0xf214, // [outline] device — astronomy, bedtime, brightness, celestial, circle
    'nightlight_round':
        0xe42f, // action — astronomy, bedtime, brightness, celestial, circle
    'nightlight_round_outlined':
        0xf215, // [outline] action — astronomy, bedtime, brightness, celestial, circle
    'nightlight_round_rounded':
        0xf0006, // [round] action — astronomy, bedtime, brightness, celestial, circle
    'nightlight_round_sharp':
        0xeb27, // [sharp] action — astronomy, bedtime, brightness, celestial, circle
    'nightlight_rounded':
        0xf0007, // [round] device — astronomy, bedtime, brightness, celestial, circle
    'nightlight_sharp':
        0xeb28, // [sharp] device — astronomy, bedtime, brightness, celestial, circle
    'nights_stay':
        0xe430, // social — astronomy, atmosphere, bedroom, climate, cloud
    'nights_stay_outlined':
        0xf216, // [outline] social — astronomy, atmosphere, bedroom, climate, cloud
    'nights_stay_rounded':
        0xf0008, // [round] social — astronomy, atmosphere, bedroom, climate, cloud
    'nights_stay_sharp':
        0xeb29, // [sharp] social — astronomy, atmosphere, bedroom, climate, cloud
    'nine_k': 0xe034, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_outlined':
        0xee26, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_plus': 0xe035, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_plus_outlined':
        0xee27, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_plus_rounded':
        0xf513, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_plus_sharp':
        0xe734, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_rounded':
        0xf514, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_k_sharp':
        0xe735, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_mp': 0xe036, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_mp_outlined':
        0xee28, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_mp_rounded':
        0xf515, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nine_mp_sharp':
        0xe736, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nineteen_mp': 0xe00a, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'nineteen_mp_outlined':
        0xedfc, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nineteen_mp_rounded':
        0xf4e9, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'nineteen_mp_sharp':
        0xe70a, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'no_accounts':
        0xe431, // action — access, access denied, account, accounts, authentication
    'no_accounts_outlined':
        0xf217, // [outline] action — access, access denied, account, accounts, authentication
    'no_accounts_rounded':
        0xf0009, // [round] action — access, access denied, account, accounts, authentication
    'no_accounts_sharp':
        0xeb2a, // [sharp] action — access, access denied, account, accounts, authentication
    'no_adult_content':
        0xf07b3, // social — access control, age rating, age restriction, block, censored
    'no_adult_content_outlined':
        0xf0703, // [outline] social — access control, age rating, age restriction, block, censored
    'no_adult_content_rounded':
        0xf080b, // [round] social — access control, age rating, age restriction, block, censored
    'no_adult_content_sharp':
        0xf075b, // [sharp] social — access control, age rating, age restriction, block, censored
    'no_backpack':
        0xe432, // places — access denied, accessory, alert, backpack, bag
    'no_backpack_outlined':
        0xf218, // [outline] places — access denied, accessory, alert, backpack, bag
    'no_backpack_rounded':
        0xf000a, // [round] places — access denied, accessory, alert, backpack, bag
    'no_backpack_sharp':
        0xeb2b, // [sharp] places — access denied, accessory, alert, backpack, bag
    'no_cell': 0xe433, // places — Android, OS, cell, device, disabled
    'no_cell_outlined':
        0xf219, // [outline] places — Android, OS, cell, device, disabled
    'no_cell_rounded':
        0xf000b, // [round] places — Android, OS, cell, device, disabled
    'no_cell_sharp':
        0xeb2c, // [sharp] places — Android, OS, cell, device, disabled
    'no_crash': 0xf07b4, // maps — accident, alert, auto, automobile, avoid
    'no_crash_outlined':
        0xf0704, // [outline] maps — accident, alert, auto, automobile, avoid
    'no_crash_rounded':
        0xf080c, // [round] maps — accident, alert, auto, automobile, avoid
    'no_crash_sharp':
        0xf075c, // [sharp] maps — accident, alert, auto, automobile, avoid
    'no_drinks':
        0xe434, // places — alcohol, alcoholic beverages, alert, bar, beverage
    'no_drinks_outlined':
        0xf21a, // [outline] places — alcohol, alcoholic beverages, alert, bar, beverage
    'no_drinks_rounded':
        0xf000c, // [round] places — alcohol, alcoholic beverages, alert, bar, beverage
    'no_drinks_sharp':
        0xeb2d, // [sharp] places — alcohol, alcoholic beverages, alert, bar, beverage
    'no_encryption':
        0xe435, // notification — alert, blocked, cancel, data breach, data security
    'no_encryption_gmailerrorred':
        0xe436, // notification — alert, blocked, cancel, data breach, data security
    'no_encryption_gmailerrorred_outlined':
        0xf21b, // [outline] notification — alert, blocked, cancel, data breach, data security
    'no_encryption_gmailerrorred_rounded':
        0xf000d, // [round] notification — alert, blocked, cancel, data breach, data security
    'no_encryption_gmailerrorred_sharp':
        0xeb2e, // [sharp] notification — alert, blocked, cancel, data breach, data security
    'no_encryption_outlined':
        0xf21c, // [outline] notification — alert, blocked, cancel, data breach, data security
    'no_encryption_rounded':
        0xf000e, // [round] notification — alert, blocked, cancel, data breach, data security
    'no_encryption_sharp':
        0xeb2f, // [sharp] notification — alert, blocked, cancel, data breach, data security
    'no_flash':
        0xe437, // places — alert, blocked, bolt, camera, camera settings
    'no_flash_outlined':
        0xf21d, // [outline] places — alert, blocked, bolt, camera, camera settings
    'no_flash_rounded':
        0xf000f, // [round] places — alert, blocked, bolt, camera, camera settings
    'no_flash_sharp':
        0xeb30, // [sharp] places — alert, blocked, bolt, camera, camera settings
    'no_food': 0xe438, // places — alert, allergy, blocked, caution, circle
    'no_food_outlined':
        0xf21e, // [outline] places — alert, allergy, blocked, caution, circle
    'no_food_rounded':
        0xf0010, // [round] places — alert, allergy, blocked, caution, circle
    'no_food_sharp':
        0xeb31, // [sharp] places — alert, allergy, blocked, caution, circle
    'no_luggage':
        0xe439, // social — access denied, airport, alert, bag, baggage
    'no_luggage_outlined':
        0xf21f, // [outline] social — access denied, airport, alert, bag, baggage
    'no_luggage_rounded':
        0xf0011, // [round] social — access denied, airport, alert, bag, baggage
    'no_luggage_sharp':
        0xeb32, // [sharp] social — access denied, airport, alert, bag, baggage
    'no_meals': 0xe43a, // maps — ban, catering, circle, crossed out, diet
    'no_meals_ouline': 0xe43b, // maps
    'no_meals_outlined':
        0xf220, // [outline] maps — ban, catering, circle, crossed out, diet
    'no_meals_rounded':
        0xf0012, // [round] maps — ban, catering, circle, crossed out, diet
    'no_meals_sharp':
        0xeb33, // [sharp] maps — ban, catering, circle, crossed out, diet
    'no_meeting_room':
        0xe43c, // places — booking, building, calendar, conference room, crossed out
    'no_meeting_room_outlined':
        0xf221, // [outline] places — booking, building, calendar, conference room, crossed out
    'no_meeting_room_rounded':
        0xf0013, // [round] places — booking, building, calendar, conference room, crossed out
    'no_meeting_room_sharp':
        0xeb34, // [sharp] places — booking, building, calendar, conference room, crossed out
    'no_photography':
        0xe43d, // places — access denied, blocked, camera, capture, circle
    'no_photography_outlined':
        0xf222, // [outline] places — access denied, blocked, camera, capture, circle
    'no_photography_rounded':
        0xf0014, // [round] places — access denied, blocked, camera, capture, circle
    'no_photography_sharp':
        0xeb35, // [sharp] places — access denied, blocked, camera, capture, circle
    'no_sim': 0xe43e, // communication — absent, alert, bar, bars, camera
    'no_sim_outlined':
        0xf223, // [outline] communication — absent, alert, bar, bars, camera
    'no_sim_rounded':
        0xf0015, // [round] communication — absent, alert, bar, bars, camera
    'no_sim_sharp':
        0xeb36, // [sharp] communication — absent, alert, bar, bars, camera
    'no_stroller':
        0xe43f, // places — access denied, area, baby, baby carriage, banned
    'no_stroller_outlined':
        0xf224, // [outline] places — access denied, area, baby, baby carriage, banned
    'no_stroller_rounded':
        0xf0016, // [round] places — access denied, area, baby, baby carriage, banned
    'no_stroller_sharp':
        0xeb37, // [sharp] places — access denied, area, baby, baby carriage, banned
    'no_transfer': 0xe440, // maps — alert, automobile, bus, cancelled, car
    'no_transfer_outlined':
        0xf225, // [outline] maps — alert, automobile, bus, cancelled, car
    'no_transfer_rounded':
        0xf0017, // [round] maps — alert, automobile, bus, cancelled, car
    'no_transfer_sharp':
        0xeb38, // [sharp] maps — alert, automobile, bus, cancelled, car
    'noise_aware':
        0xf07b5, // action — access, accessibility, acoustic, alert, ambient
    'noise_aware_outlined':
        0xf0705, // [outline] action — access, accessibility, acoustic, alert, ambient
    'noise_aware_rounded':
        0xf080d, // [round] action — access, accessibility, acoustic, alert, ambient
    'noise_aware_sharp':
        0xf075d, // [sharp] action — access, accessibility, acoustic, alert, ambient
    'noise_control_off':
        0xf07b6, // action — ambient sound off, audio, audio off, aware, blocked
    'noise_control_off_outlined':
        0xf0706, // [outline] action — ambient sound off, audio, audio off, aware, blocked
    'noise_control_off_rounded':
        0xf080e, // [round] action — ambient sound off, audio, audio off, aware, blocked
    'noise_control_off_sharp':
        0xf075e, // [sharp] action — ambient sound off, audio, audio off, aware, blocked
    'nordic_walking':
        0xe441, // social — active, activity, athlete, athletic, body
    'nordic_walking_outlined':
        0xf226, // [outline] social — active, activity, athlete, athletic, body
    'nordic_walking_rounded':
        0xf0018, // [round] social — active, activity, athlete, athletic, body
    'nordic_walking_sharp':
        0xeb39, // [sharp] social — active, activity, athlete, athletic, body
    'north':
        0xe442, // navigation — arrow, arrow up, compass, destination, direction
    'north_east':
        0xe443, // navigation — arrow, corner, diagonal, direction, direction indicator
    'north_east_outlined':
        0xf227, // [outline] navigation — arrow, corner, diagonal, direction, direction indicator
    'north_east_rounded':
        0xf0019, // [round] navigation — arrow, corner, diagonal, direction, direction indicator
    'north_east_sharp':
        0xeb3a, // [sharp] navigation — arrow, corner, diagonal, direction, direction indicator
    'north_outlined':
        0xf228, // [outline] navigation — arrow, arrow up, compass, destination, direction
    'north_rounded':
        0xf001a, // [round] navigation — arrow, arrow up, compass, destination, direction
    'north_sharp':
        0xeb3b, // [sharp] navigation — arrow, arrow up, compass, destination, direction
    'north_west':
        0xe444, // navigation — angle, arrow, corner, diagonal, direction
    'north_west_outlined':
        0xf229, // [outline] navigation — angle, arrow, corner, diagonal, direction
    'north_west_rounded':
        0xf001b, // [round] navigation — angle, arrow, corner, diagonal, direction
    'north_west_sharp':
        0xeb3c, // [sharp] navigation — angle, arrow, corner, diagonal, direction
    'not_accessible':
        0xe445, // action — access denied, accessibility, accessible, alert, blocked
    'not_accessible_outlined':
        0xf22a, // [outline] action — access denied, accessibility, accessible, alert, blocked
    'not_accessible_rounded':
        0xf001c, // [round] action — access denied, accessibility, accessible, alert, blocked
    'not_accessible_sharp':
        0xeb3d, // [sharp] action — access denied, accessibility, accessible, alert, blocked
    'not_interested': 0xe446, // av — alert, ban, block, cancel, circle
    'not_interested_outlined':
        0xf22b, // [outline] av — alert, ban, block, cancel, circle
    'not_interested_rounded':
        0xf001d, // [round] av — alert, ban, block, cancel, circle
    'not_interested_sharp':
        0xeb3e, // [sharp] av — alert, ban, block, cancel, circle
    'not_listed_location':
        0xe447, // maps — ?, address, ask, assistance, clarity
    'not_listed_location_outlined':
        0xf22c, // [outline] maps — ?, address, ask, assistance, clarity
    'not_listed_location_rounded':
        0xf001e, // [round] maps — ?, address, ask, assistance, clarity
    'not_listed_location_sharp':
        0xeb3f, // [sharp] maps — ?, address, ask, assistance, clarity
    'not_started': 0xe448, // action — 0, beginning, circle, circular, empty
    'not_started_outlined':
        0xf22d, // [outline] action — 0, beginning, circle, circular, empty
    'not_started_rounded':
        0xf001f, // [round] action — 0, beginning, circle, circular, empty
    'not_started_sharp':
        0xeb40, // [sharp] action — 0, beginning, circle, circular, empty
    'note': 0xe449, // av — attachment, blank, bookmark, doc, document
    'note_add': 0xe44a, // action — +, add, add document, add note, create
    'note_add_outlined':
        0xf22e, // [outline] action — +, add, add document, add note, create
    'note_add_rounded':
        0xf0020, // [round] action — +, add, add document, add note, create
    'note_add_sharp':
        0xeb41, // [sharp] action — +, add, add document, add note, create
    'note_alt': 0xe44b, // device — alt, article, clipboard, compose, content
    'note_alt_outlined':
        0xf22f, // [outline] device — alt, article, clipboard, compose, content
    'note_alt_rounded':
        0xf0021, // [round] device — alt, article, clipboard, compose, content
    'note_alt_sharp':
        0xeb42, // [sharp] device — alt, article, clipboard, compose, content
    'note_outlined':
        0xf230, // [outline] av — attachment, blank, bookmark, doc, document
    'note_rounded':
        0xf0022, // [round] av — attachment, blank, bookmark, doc, document
    'note_sharp':
        0xeb43, // [sharp] av — attachment, blank, bookmark, doc, document
    'notes': 0xe44c, // editor — add, article, checklist, comment, content
    'notes_outlined':
        0xf231, // [outline] editor — add, article, checklist, comment, content
    'notes_rounded':
        0xf0023, // [round] editor — add, article, checklist, comment, content
    'notes_sharp':
        0xeb44, // [sharp] editor — add, article, checklist, comment, content
    'notification_add': 0xe44d, // social — +, active, add, addition, alarm
    'notification_add_outlined':
        0xf232, // [outline] social — +, active, add, addition, alarm
    'notification_add_rounded':
        0xf0024, // [round] social — +, active, add, addition, alarm
    'notification_add_sharp':
        0xeb45, // [sharp] social — +, active, add, addition, alarm
    'notification_important':
        0xe44e, // alert — !, active, alarm, alert, attention
    'notification_important_outlined':
        0xf233, // [outline] alert — !, active, alarm, alert, attention
    'notification_important_rounded':
        0xf0025, // [round] alert — !, active, alarm, alert, attention
    'notification_important_sharp':
        0xeb46, // [sharp] alert — !, active, alarm, alert, attention
    'notifications':
        0xe44f, // social — active, alarm, alert, announcement, bell
    'notifications_active':
        0xe450, // social — active, alarm, alert, attention, bell
    'notifications_active_outlined':
        0xf234, // [outline] social — active, alarm, alert, attention, bell
    'notifications_active_rounded':
        0xf0026, // [round] social — active, alarm, alert, attention, bell
    'notifications_active_sharp':
        0xeb47, // [sharp] social — active, alarm, alert, attention, bell
    'notifications_none':
        0xe451, // social — alarm, alert, announcement, bell, communication
    'notifications_none_outlined':
        0xf235, // [outline] social — alarm, alert, announcement, bell, communication
    'notifications_none_rounded':
        0xf0027, // [round] social — alarm, alert, announcement, bell, communication
    'notifications_none_sharp':
        0xeb48, // [sharp] social — alarm, alert, announcement, bell, communication
    'notifications_off':
        0xe452, // social — active, alarm, alarm off, alert, alert off
    'notifications_off_outlined':
        0xf236, // [outline] social — active, alarm, alarm off, alert, alert off
    'notifications_off_rounded':
        0xf0028, // [round] social — active, alarm, alarm off, alert, alert off
    'notifications_off_sharp':
        0xeb49, // [sharp] social — active, alarm, alarm off, alert, alert off
    'notifications_on':
        0xe450, // social — active, alarm, alert, attention, bell
    'notifications_on_outlined':
        0xf234, // [outline] social — active, alarm, alert, attention, bell
    'notifications_on_rounded':
        0xf0026, // [round] social — active, alarm, alert, attention, bell
    'notifications_on_sharp':
        0xeb47, // [sharp] social — active, alarm, alert, attention, bell
    'notifications_outlined':
        0xf237, // [outline] social — active, alarm, alert, announcement, bell
    'notifications_paused':
        0xe453, // social — active, alarm, alert, attention, bell
    'notifications_paused_outlined':
        0xf238, // [outline] social — active, alarm, alert, attention, bell
    'notifications_paused_rounded':
        0xf0029, // [round] social — active, alarm, alert, attention, bell
    'notifications_paused_sharp':
        0xeb4a, // [sharp] social — active, alarm, alert, attention, bell
    'notifications_rounded':
        0xf002a, // [round] social — active, alarm, alert, announcement, bell
    'notifications_sharp':
        0xeb4b, // [sharp] social — active, alarm, alert, announcement, bell
    'now_wallpaper':
        0xe6ca, // device — abstract, background, clouds, customize, dash
    'now_wallpaper_outlined':
        0xf4ad, // [outline] device — abstract, background, clouds, customize, dash
    'now_wallpaper_rounded':
        0xf029f, // [round] device — abstract, background, clouds, customize, dash
    'now_wallpaper_sharp':
        0xedc0, // [sharp] device — abstract, background, clouds, customize, dash
    'now_widgets': 0xe6e6, // device — add, arrange, blocks, box, boxes
    'now_widgets_outlined':
        0xf4c7, // [outline] device — add, arrange, blocks, box, boxes
    'now_widgets_rounded':
        0xf02b9, // [round] device — add, arrange, blocks, box, boxes
    'now_widgets_sharp':
        0xedda, // [sharp] device — add, arrange, blocks, box, boxes
    'numbers': 0xf0542, // editor — active, bullet, busy, choice, circle
    'numbers_outlined':
        0xf063a, // [outline] editor — active, bullet, busy, choice, circle
    'numbers_rounded':
        0xf0359, // [round] editor — active, bullet, busy, choice, circle
    'numbers_sharp':
        0xf044c, // [sharp] editor — active, bullet, busy, choice, circle
    'offline_bolt': 0xe454, // action — adapter, alert, batteries, bolt, charger
    'offline_bolt_outlined':
        0xf239, // [outline] action — adapter, alert, batteries, bolt, charger
    'offline_bolt_rounded':
        0xf002b, // [round] action — adapter, alert, batteries, bolt, charger
    'offline_bolt_sharp':
        0xeb4c, // [sharp] action — adapter, alert, batteries, bolt, charger
    'offline_pin':
        0xe455, // action — approve, available offline, cache, check, checkmark
    'offline_pin_outlined':
        0xf23a, // [outline] action — approve, available offline, cache, check, checkmark
    'offline_pin_rounded':
        0xf002c, // [round] action — approve, available offline, cache, check, checkmark
    'offline_pin_sharp':
        0xeb4d, // [sharp] action — approve, available offline, cache, check, checkmark
    'offline_share': 0xe456, // navigation — Android, OS, arrow, bluetooth, cell
    'offline_share_outlined':
        0xf23b, // [outline] navigation — Android, OS, arrow, bluetooth, cell
    'offline_share_rounded':
        0xf002d, // [round] navigation — Android, OS, arrow, bluetooth, cell
    'offline_share_sharp':
        0xeb4e, // [sharp] navigation — Android, OS, arrow, bluetooth, cell
    'oil_barrel':
        0xf07b7, // home — barrel, black gold, commodity, container, crude oil
    'oil_barrel_outlined':
        0xf0707, // [outline] home — barrel, black gold, commodity, container, crude oil
    'oil_barrel_rounded':
        0xf080f, // [round] home — barrel, black gold, commodity, container, crude oil
    'oil_barrel_sharp':
        0xf075f, // [sharp] home — barrel, black gold, commodity, container, crude oil
    'on_device_training': 0xf07b8, // action — ai, analytics, arrow, bar, brain
    'on_device_training_outlined':
        0xf0708, // [outline] action — ai, analytics, arrow, bar, brain
    'on_device_training_rounded':
        0xf0810, // [round] action — ai, analytics, arrow, bar, brain
    'on_device_training_sharp':
        0xf0760, // [sharp] action — ai, analytics, arrow, bar, brain
    'ondemand_video':
        0xe457, // notification — Android, OS, antenna, broadcast, broadcasting
    'ondemand_video_outlined':
        0xf23c, // [outline] notification — Android, OS, antenna, broadcast, broadcasting
    'ondemand_video_rounded':
        0xf002e, // [round] notification — Android, OS, antenna, broadcast, broadcasting
    'ondemand_video_sharp':
        0xeb4f, // [sharp] notification — Android, OS, antenna, broadcast, broadcasting
    'one_k': 0xe00b, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_outlined':
        0xedfd, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_plus': 0xe00c, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_plus_outlined':
        0xedfe, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_plus_rounded':
        0xf4ea, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_plus_sharp':
        0xe70b, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_rounded':
        0xf4eb, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_k_sharp':
        0xe70c, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'one_x_mobiledata': 0xe00d,
    'one_x_mobiledata_outlined': 0xedff,
    'one_x_mobiledata_rounded': 0xf4ec,
    'one_x_mobiledata_sharp': 0xe70d,
    'onetwothree': 0xf04b5,
    'onetwothree_outlined': 0xf05b0,
    'onetwothree_rounded': 0xe340,
    'onetwothree_sharp': 0xf03c2,
    'online_prediction':
        0xe458, // action — ai, analysis, analytics, bulb, business
    'online_prediction_outlined':
        0xf23d, // [outline] action — ai, analysis, analytics, bulb, business
    'online_prediction_rounded':
        0xf002f, // [round] action — ai, analysis, analytics, bulb, business
    'online_prediction_sharp':
        0xeb50, // [sharp] action — ai, analysis, analytics, bulb, business
    'opacity': 0xe459, // action — adjustment, appearance, blend, box, color
    'opacity_outlined':
        0xf23e, // [outline] action — adjustment, appearance, blend, box, color
    'opacity_rounded':
        0xf0030, // [round] action — adjustment, appearance, blend, box, color
    'opacity_sharp':
        0xeb51, // [sharp] action — adjustment, appearance, blend, box, color
    'open_in_browser':
        0xe45a, // action — access, arrow, box, browser, browser window
    'open_in_browser_outlined':
        0xf23f, // [outline] action — access, arrow, box, browser, browser window
    'open_in_browser_rounded':
        0xf0031, // [round] action — access, arrow, box, browser, browser window
    'open_in_browser_sharp':
        0xeb52, // [sharp] action — access, arrow, box, browser, browser window
    'open_in_full': 0xe45b, // action — arrow, arrows, box, corners, dimensions
    'open_in_full_outlined':
        0xf240, // [outline] action — arrow, arrows, box, corners, dimensions
    'open_in_full_rounded':
        0xf0032, // [round] action — arrow, arrows, box, corners, dimensions
    'open_in_full_sharp':
        0xeb53, // [sharp] action — arrow, arrows, box, corners, dimensions
    'open_in_new': 0xe45c, // action — access, arrow, box, depart, destination
    'open_in_new_off':
        0xe45d, // action — arrow, blocked, blocked link, box, broken arrow
    'open_in_new_off_outlined':
        0xf241, // [outline] action — arrow, blocked, blocked link, box, broken arrow
    'open_in_new_off_rounded':
        0xf0033, // [round] action — arrow, blocked, blocked link, box, broken arrow
    'open_in_new_off_sharp':
        0xeb54, // [sharp] action — arrow, blocked, blocked link, box, broken arrow
    'open_in_new_outlined':
        0xf242, // [outline] action — access, arrow, box, depart, destination
    'open_in_new_rounded':
        0xf0034, // [round] action — access, arrow, box, depart, destination
    'open_in_new_sharp':
        0xeb55, // [sharp] action — access, arrow, box, depart, destination
    'open_with':
        0xe45e, // action — arrow, arrows, arrows pointing out, box, corners
    'open_with_outlined':
        0xf243, // [outline] action — arrow, arrows, arrows pointing out, box, corners
    'open_with_rounded':
        0xf0035, // [round] action — arrow, arrows, arrows pointing out, box, corners
    'open_with_sharp':
        0xeb56, // [sharp] action — arrow, arrows, arrows pointing out, box, corners
    'other_houses':
        0xe45f, // places — abodes, architecture, area, buildings, collection of homes
    'other_houses_outlined':
        0xf244, // [outline] places — abodes, architecture, area, buildings, collection of homes
    'other_houses_rounded':
        0xf0036, // [round] places — abodes, architecture, area, buildings, collection of homes
    'other_houses_sharp':
        0xeb57, // [sharp] places — abodes, architecture, area, buildings, collection of homes
    'outbond': 0xe460, // action — arrow, away, box, circle, diagonal arrow
    'outbond_outlined':
        0xf245, // [outline] action — arrow, away, box, circle, diagonal arrow
    'outbond_rounded':
        0xf0037, // [round] action — arrow, away, box, circle, diagonal arrow
    'outbond_sharp':
        0xeb58, // [sharp] action — arrow, away, box, circle, diagonal arrow
    'outbound': 0xe461, // action — arrow, away, box, circle, diagonal arrow
    'outbound_outlined':
        0xf246, // [outline] action — arrow, away, box, circle, diagonal arrow
    'outbound_rounded':
        0xf0038, // [round] action — arrow, away, box, circle, diagonal arrow
    'outbound_sharp':
        0xeb59, // [sharp] action — arrow, away, box, circle, diagonal arrow
    'outbox': 0xe462, // action — arrow, box, compartment, container, deliver
    'outbox_outlined':
        0xf247, // [outline] action — arrow, box, compartment, container, deliver
    'outbox_rounded':
        0xf0039, // [round] action — arrow, box, compartment, container, deliver
    'outbox_sharp':
        0xeb5a, // [sharp] action — arrow, box, compartment, container, deliver
    'outdoor_grill':
        0xe463, // social — appliance, backyard, barbecue, barbeque, bbq
    'outdoor_grill_outlined':
        0xf248, // [outline] social — appliance, backyard, barbecue, barbeque, bbq
    'outdoor_grill_rounded':
        0xf003a, // [round] social — appliance, backyard, barbecue, barbeque, bbq
    'outdoor_grill_sharp':
        0xeb5b, // [sharp] social — appliance, backyard, barbecue, barbeque, bbq
    'outgoing_mail':
        0xe464, // action — address, arrow, arrows, communication, delivery
    'outlet':
        0xe465, // action — adapter, charge, charging point, connect, connecter
    'outlet_outlined':
        0xf249, // [outline] action — adapter, charge, charging point, connect, connecter
    'outlet_rounded':
        0xf003b, // [round] action — adapter, charge, charging point, connect, connecter
    'outlet_sharp':
        0xeb5c, // [sharp] action — adapter, charge, charging point, connect, connecter
    'outlined_flag':
        0xe466, // content — achievement, banner, bookmark, country, empty
    'outlined_flag_outlined':
        0xf24a, // [outline] content — achievement, banner, bookmark, country, empty
    'outlined_flag_rounded':
        0xf003c, // [round] content — achievement, banner, bookmark, country, empty
    'outlined_flag_sharp':
        0xeb5d, // [sharp] content — achievement, banner, bookmark, country, empty
    'output': 0xf0543, // action — area, arrows, box, corners, diagonal
    'output_outlined':
        0xf063b, // [outline] action — area, arrows, box, corners, diagonal
    'output_rounded':
        0xf035a, // [round] action — area, arrows, box, corners, diagonal
    'output_sharp':
        0xf044d, // [sharp] action — area, arrows, box, corners, diagonal
    'padding':
        0xe467, // editor — adjust, alignment, arrangement, arrows, boundaries
    'padding_outlined':
        0xf24b, // [outline] editor — adjust, alignment, arrangement, arrows, boundaries
    'padding_rounded':
        0xf003d, // [round] editor — adjust, alignment, arrangement, arrows, boundaries
    'padding_sharp':
        0xeb5e, // [sharp] editor — adjust, alignment, arrangement, arrows, boundaries
    'pages': 0xe468, // social — archive, article, bundle, content, copy
    'pages_outlined':
        0xf24c, // [outline] social — archive, article, bundle, content, copy
    'pages_rounded':
        0xf003e, // [round] social — archive, article, bundle, content, copy
    'pages_sharp':
        0xeb5f, // [sharp] social — archive, article, bundle, content, copy
    'pageview': 0xe469, // action — add, book, browse, circle, content
    'pageview_outlined':
        0xf24d, // [outline] action — add, book, browse, circle, content
    'pageview_rounded':
        0xf003f, // [round] action — add, book, browse, circle, content
    'pageview_sharp':
        0xeb60, // [sharp] action — add, book, browse, circle, content
    'paid': 0xe46a, // action — amount, balance, banknote, bill, business
    'paid_outlined':
        0xf24e, // [outline] action — amount, balance, banknote, bill, business
    'paid_rounded':
        0xf0040, // [round] action — amount, balance, banknote, bill, business
    'paid_sharp':
        0xeb61, // [sharp] action — amount, balance, banknote, bill, business
    'palette': 0xe46b, // image — appearance, art, artist, artistic, brush
    'palette_outlined':
        0xf24f, // [outline] image — appearance, art, artist, artistic, brush
    'palette_rounded':
        0xf0041, // [round] image — appearance, art, artist, artistic, brush
    'palette_sharp':
        0xeb62, // [sharp] image — appearance, art, artist, artistic, brush
    'pallet': 0xf086f, // hardware — bars, box, cargo, commercial, construction
    'pan_tool': 0xe46c, // action — cursor, drag, editor, fingers, gesture
    'pan_tool_alt':
        0xf0544, // action — cursor, digital hand, drag, fingers, gesture
    'pan_tool_alt_outlined':
        0xf063c, // [outline] action — cursor, digital hand, drag, fingers, gesture
    'pan_tool_alt_rounded':
        0xf035b, // [round] action — cursor, digital hand, drag, fingers, gesture
    'pan_tool_alt_sharp':
        0xf044e, // [sharp] action — cursor, digital hand, drag, fingers, gesture
    'pan_tool_outlined':
        0xf250, // [outline] action — cursor, drag, editor, fingers, gesture
    'pan_tool_rounded':
        0xf0042, // [round] action — cursor, drag, editor, fingers, gesture
    'pan_tool_sharp':
        0xeb63, // [sharp] action — cursor, drag, editor, fingers, gesture
    'panorama': 0xe46d, // image — ad, advertisement, advertising, angle, banner
    'panorama_fish_eye':
        0xe46e, // image — angle, basic shape, circle, circular, design element
    'panorama_fish_eye_outlined':
        0xf251, // [outline] image — angle, basic shape, circle, circular, design element
    'panorama_fish_eye_rounded':
        0xf0043, // [round] image — angle, basic shape, circle, circular, design element
    'panorama_fish_eye_sharp':
        0xeb64, // [sharp] image — angle, basic shape, circle, circular, design element
    'panorama_fisheye': 0xe46e,
    'panorama_fisheye_outlined': 0xf251,
    'panorama_fisheye_rounded': 0xf0043,
    'panorama_fisheye_sharp': 0xeb64,
    'panorama_horizontal':
        0xe46f, // image — angle, aspect ratio, camera, composition, display
    'panorama_horizontal_outlined':
        0xf252, // [outline] image — angle, aspect ratio, camera, composition, display
    'panorama_horizontal_rounded':
        0xf0044, // [round] image — angle, aspect ratio, camera, composition, display
    'panorama_horizontal_select':
        0xe470, // image — angle, horizontal, image, panorama, photo
    'panorama_horizontal_select_outlined':
        0xf253, // [outline] image — angle, horizontal, image, panorama, photo
    'panorama_horizontal_select_rounded':
        0xf0045, // [round] image — angle, horizontal, image, panorama, photo
    'panorama_horizontal_select_sharp':
        0xeb65, // [sharp] image — angle, horizontal, image, panorama, photo
    'panorama_horizontal_sharp':
        0xeb66, // [sharp] image — angle, aspect ratio, camera, composition, display
    'panorama_outlined':
        0xf254, // [outline] image — ad, advertisement, advertising, angle, banner
    'panorama_photosphere':
        0xe471, // image — 360, angle, ar, augmented reality, camera
    'panorama_photosphere_outlined':
        0xf255, // [outline] image — 360, angle, ar, augmented reality, camera
    'panorama_photosphere_rounded':
        0xf0046, // [round] image — 360, angle, ar, augmented reality, camera
    'panorama_photosphere_select':
        0xe472, // image — angle, horizontal, image, panorama, photo
    'panorama_photosphere_select_outlined':
        0xf256, // [outline] image — angle, horizontal, image, panorama, photo
    'panorama_photosphere_select_rounded':
        0xf0047, // [round] image — angle, horizontal, image, panorama, photo
    'panorama_photosphere_select_sharp':
        0xeb67, // [sharp] image — angle, horizontal, image, panorama, photo
    'panorama_photosphere_sharp':
        0xeb68, // [sharp] image — 360, angle, ar, augmented reality, camera
    'panorama_rounded':
        0xf0048, // [round] image — ad, advertisement, advertising, angle, banner
    'panorama_sharp':
        0xeb69, // [sharp] image — ad, advertisement, advertising, angle, banner
    'panorama_vertical':
        0xe473, // image — angle, aspect ratio, building, camera, capture
    'panorama_vertical_outlined':
        0xf257, // [outline] image — angle, aspect ratio, building, camera, capture
    'panorama_vertical_rounded':
        0xf0049, // [round] image — angle, aspect ratio, building, camera, capture
    'panorama_vertical_select':
        0xe474, // image — angle, image, panorama, photo, photography
    'panorama_vertical_select_outlined':
        0xf258, // [outline] image — angle, image, panorama, photo, photography
    'panorama_vertical_select_rounded':
        0xf004a, // [round] image — angle, image, panorama, photo, photography
    'panorama_vertical_select_sharp':
        0xeb6a, // [sharp] image — angle, image, panorama, photo, photography
    'panorama_vertical_sharp':
        0xeb6b, // [sharp] image — angle, aspect ratio, building, camera, capture
    'panorama_wide_angle':
        0xe475, // image — adjust, album, angle, aperture, broad
    'panorama_wide_angle_outlined':
        0xf259, // [outline] image — adjust, album, angle, aperture, broad
    'panorama_wide_angle_rounded':
        0xf004b, // [round] image — adjust, album, angle, aperture, broad
    'panorama_wide_angle_select':
        0xe476, // image — angle, image, panorama, photo, photography
    'panorama_wide_angle_select_outlined':
        0xf25a, // [outline] image — angle, image, panorama, photo, photography
    'panorama_wide_angle_select_rounded':
        0xf004c, // [round] image — angle, image, panorama, photo, photography
    'panorama_wide_angle_select_sharp':
        0xeb6c, // [sharp] image — angle, image, panorama, photo, photography
    'panorama_wide_angle_sharp':
        0xeb6d, // [sharp] image — adjust, album, angle, aperture, broad
    'paragliding':
        0xe477, // social — activity, adventure, aerial, air, altitude
    'paragliding_outlined':
        0xf25b, // [outline] social — activity, adventure, aerial, air, altitude
    'paragliding_rounded':
        0xf004d, // [round] social — activity, adventure, aerial, air, altitude
    'paragliding_sharp':
        0xeb6e, // [sharp] social — activity, adventure, aerial, air, altitude
    'park': 0xe478, // maps — area, attraction, destination, environment, fresh
    'park_outlined':
        0xf25c, // [outline] maps — area, attraction, destination, environment, fresh
    'park_rounded':
        0xf004e, // [round] maps — area, attraction, destination, environment, fresh
    'park_sharp':
        0xeb6f, // [sharp] maps — area, attraction, destination, environment, fresh
    'party_mode':
        0xe479, // social — bright, camera, camera mode, celebration, celebration mode
    'party_mode_outlined':
        0xf25d, // [outline] social — bright, camera, camera mode, celebration, celebration mode
    'party_mode_rounded':
        0xf004f, // [round] social — bright, camera, camera mode, celebration, celebration mode
    'party_mode_sharp':
        0xeb70, // [sharp] social — bright, camera, camera mode, celebration, celebration mode
    'password':
        0xe47a, // device — access, access code, account, authentication, authorization
    'password_outlined':
        0xf25e, // [outline] device — access, access code, account, authentication, authorization
    'password_rounded':
        0xf0050, // [round] device — access, access code, account, authentication, authorization
    'password_sharp':
        0xeb71, // [sharp] device — access, access code, account, authentication, authorization
    'paste': 0xe192, // content — add, attach, clip, clipboard, content
    'paste_outlined':
        0xef82, // [outline] content — add, attach, clip, clipboard, content
    'paste_rounded':
        0xf66f, // [round] content — add, attach, clip, clipboard, content
    'paste_sharp':
        0xe890, // [sharp] content — add, attach, clip, clipboard, content
    'pattern':
        0xe47b, // device — abstract, appearance, arrangement, background, background design
    'pattern_outlined':
        0xf25f, // [outline] device — abstract, appearance, arrangement, background, background design
    'pattern_rounded':
        0xf0051, // [round] device — abstract, appearance, arrangement, background, background design
    'pattern_sharp':
        0xeb72, // [sharp] device — abstract, appearance, arrangement, background, background design
    'pause': 0xe47c, // av — audio, break, command, function, halt
    'pause_circle': 0xe47d, // av — audio, bars, break, circle, circular
    'pause_circle_filled': 0xe47e, // av — audio, bars, break, circle, circular
    'pause_circle_filled_outlined':
        0xf260, // [outline] av — audio, bars, break, circle, circular
    'pause_circle_filled_rounded':
        0xf0052, // [round] av — audio, bars, break, circle, circular
    'pause_circle_filled_sharp':
        0xeb73, // [sharp] av — audio, bars, break, circle, circular
    'pause_circle_outline': 0xe47f, // av — audio, bars, break, circle, circular
    'pause_circle_outline_outlined':
        0xf261, // [outline] av — audio, bars, break, circle, circular
    'pause_circle_outline_rounded':
        0xf0053, // [round] av — audio, bars, break, circle, circular
    'pause_circle_outline_sharp':
        0xeb74, // [sharp] av — audio, bars, break, circle, circular
    'pause_circle_outlined':
        0xf262, // [outline] av — audio, bars, break, circle, circular
    'pause_circle_rounded':
        0xf0054, // [round] av — audio, bars, break, circle, circular
    'pause_circle_sharp':
        0xeb75, // [sharp] av — audio, bars, break, circle, circular
    'pause_outlined':
        0xf263, // [outline] av — audio, break, command, function, halt
    'pause_presentation':
        0xe480, // communication — application desktop, audio player, break, device, display
    'pause_presentation_outlined':
        0xf264, // [outline] communication — application desktop, audio player, break, device, display
    'pause_presentation_rounded':
        0xf0055, // [round] communication — application desktop, audio player, break, device, display
    'pause_presentation_sharp':
        0xeb76, // [sharp] communication — application desktop, audio player, break, device, display
    'pause_rounded':
        0xf0056, // [round] av — audio, break, command, function, halt
    'pause_sharp': 0xeb77, // [sharp] av — audio, break, command, function, halt
    'payment':
        0xe481, // action — account, account information, amex, balance, bank
    'payment_outlined':
        0xf265, // [outline] action — account, account information, amex, balance, bank
    'payment_rounded':
        0xf0057, // [round] action — account, account information, amex, balance, bank
    'payment_sharp':
        0xeb78, // [sharp] action — account, account information, amex, balance, bank
    'payments': 0xe482, // navigation — bank, banking, bill, bills, buy
    'payments_outlined':
        0xf266, // [outline] navigation — bank, banking, bill, bills, buy
    'payments_rounded':
        0xf0058, // [round] navigation — bank, banking, bill, bills, buy
    'payments_sharp':
        0xeb79, // [sharp] navigation — bank, banking, bill, bills, buy
    'paypal': 0xf0545, // brand logo
    'paypal_outlined': 0xf063d, // [outline] brand logo
    'paypal_rounded': 0xf035c, // [round] brand logo
    'paypal_sharp': 0xf044f, // [sharp] brand logo
    'pedal_bike': 0xe483, // maps — active, automobile, bicycle, bike, car
    'pedal_bike_outlined':
        0xf267, // [outline] maps — active, automobile, bicycle, bike, car
    'pedal_bike_rounded':
        0xf0059, // [round] maps — active, automobile, bicycle, bike, car
    'pedal_bike_sharp':
        0xeb7a, // [sharp] maps — active, automobile, bicycle, bike, car
    'pending': 0xe484, // action — accordion, arrow down, bottom, choose, circle
    'pending_actions':
        0xe485, // action — agenda, alert, backlog, calendar, clipboard
    'pending_actions_outlined':
        0xf268, // [outline] action — agenda, alert, backlog, calendar, clipboard
    'pending_actions_rounded':
        0xf005a, // [round] action — agenda, alert, backlog, calendar, clipboard
    'pending_actions_sharp':
        0xeb7b, // [sharp] action — agenda, alert, backlog, calendar, clipboard
    'pending_outlined':
        0xf269, // [outline] action — accordion, arrow down, bottom, choose, circle
    'pending_rounded':
        0xf005b, // [round] action — accordion, arrow down, bottom, choose, circle
    'pending_sharp':
        0xeb7c, // [sharp] action — accordion, arrow down, bottom, choose, circle
    'pentagon': 0xf0546, // editor — abstract, angled, clean, concept, facet
    'pentagon_outlined':
        0xf063e, // [outline] editor — abstract, angled, clean, concept, facet
    'pentagon_rounded':
        0xf035d, // [round] editor — abstract, angled, clean, concept, facet
    'pentagon_sharp':
        0xf0450, // [sharp] editor — abstract, angled, clean, concept, facet
    'people':
        0xe486, // social — accounts, administration, audience, committee, community
    'people_alt':
        0xe487, // social — accounts, administration, audience, committee, community
    'people_alt_outlined':
        0xf26a, // [outline] social — accounts, administration, audience, committee, community
    'people_alt_rounded':
        0xf005c, // [round] social — accounts, administration, audience, committee, community
    'people_alt_sharp':
        0xeb7d, // [sharp] social — accounts, administration, audience, committee, community
    'people_outline':
        0xe488, // social — accounts, administration, audience, committee, community
    'people_outline_outlined':
        0xf26b, // [outline] social — accounts, administration, audience, committee, community
    'people_outline_rounded':
        0xf005d, // [round] social — accounts, administration, audience, committee, community
    'people_outline_sharp':
        0xeb7e, // [sharp] social — accounts, administration, audience, committee, community
    'people_outlined':
        0xf26c, // [outline] social — accounts, administration, audience, committee, community
    'people_rounded':
        0xf005e, // [round] social — accounts, administration, audience, committee, community
    'people_sharp':
        0xeb7f, // [sharp] social — accounts, administration, audience, committee, community
    'percent':
        0xf0547, // action — analysis, arithmetic, calculation, chart, circle
    'percent_outlined':
        0xf063f, // [outline] action — analysis, arithmetic, calculation, chart, circle
    'percent_rounded':
        0xf035e, // [round] action — analysis, arithmetic, calculation, chart, circle
    'percent_sharp':
        0xf0451, // [sharp] action — analysis, arithmetic, calculation, chart, circle
    'perm_camera_mic':
        0xe489, // action — access, audio, camera, capture, communication
    'perm_camera_mic_outlined':
        0xf26d, // [outline] action — access, audio, camera, capture, communication
    'perm_camera_mic_rounded':
        0xf005f, // [round] action — access, audio, camera, capture, communication
    'perm_camera_mic_sharp':
        0xeb80, // [sharp] action — access, audio, camera, capture, communication
    'perm_contact_cal':
        0xe48a, // action — account, address book, appointment, calendar, contact
    'perm_contact_cal_outlined':
        0xf26e, // [outline] action — account, address book, appointment, calendar, contact
    'perm_contact_cal_rounded':
        0xf0060, // [round] action — account, address book, appointment, calendar, contact
    'perm_contact_cal_sharp':
        0xeb81, // [sharp] action — account, address book, appointment, calendar, contact
    'perm_contact_calendar':
        0xe48a, // action — account, address book, appointment, calendar, contact
    'perm_contact_calendar_outlined':
        0xf26e, // [outline] action — account, address book, appointment, calendar, contact
    'perm_contact_calendar_rounded':
        0xf0060, // [round] action — account, address book, appointment, calendar, contact
    'perm_contact_calendar_sharp':
        0xeb81, // [sharp] action — account, address book, appointment, calendar, contact
    'perm_data_setting':
        0xe48b, // action — access, adjustments, administration, cloud, cog
    'perm_data_setting_outlined':
        0xf26f, // [outline] action — access, adjustments, administration, cloud, cog
    'perm_data_setting_rounded':
        0xf0061, // [round] action — access, adjustments, administration, cloud, cog
    'perm_data_setting_sharp':
        0xeb82, // [sharp] action — access, adjustments, administration, cloud, cog
    'perm_device_info': 0xe48c,
    'perm_device_info_outlined': 0xf270,
    'perm_device_info_rounded': 0xf0062,
    'perm_device_info_sharp': 0xeb83,
    'perm_device_information':
        0xe48c, // action — Android, OS, about, alert, announcement
    'perm_device_information_outlined':
        0xf270, // [outline] action — Android, OS, about, alert, announcement
    'perm_device_information_rounded':
        0xf0062, // [round] action — Android, OS, about, alert, announcement
    'perm_device_information_sharp':
        0xeb83, // [sharp] action — Android, OS, about, alert, announcement
    'perm_identity':
        0xe48d, // action — account, avatar, avatar filled, avatar outline, body
    'perm_identity_outlined':
        0xf271, // [outline] action — account, avatar, avatar filled, avatar outline, body
    'perm_identity_rounded':
        0xf0063, // [round] action — account, avatar, avatar filled, avatar outline, body
    'perm_identity_sharp':
        0xeb84, // [sharp] action — account, avatar, avatar filled, avatar outline, body
    'perm_media':
        0xe48e, // action — archive, arrangement, content, copy, digital library
    'perm_media_outlined':
        0xf272, // [outline] action — archive, arrangement, content, copy, digital library
    'perm_media_rounded':
        0xf0064, // [round] action — archive, arrangement, content, copy, digital library
    'perm_media_sharp':
        0xeb85, // [sharp] action — archive, arrangement, content, copy, digital library
    'perm_phone_msg': 0xe48f, // action — always, avatar, bubble, business, call
    'perm_phone_msg_outlined':
        0xf273, // [outline] action — always, avatar, bubble, business, call
    'perm_phone_msg_rounded':
        0xf0065, // [round] action — always, avatar, bubble, business, call
    'perm_phone_msg_sharp':
        0xeb86, // [sharp] action — always, avatar, bubble, business, call
    'perm_scan_wifi':
        0xe490, // action — access, alert, always on, announcement, antenna
    'perm_scan_wifi_outlined':
        0xf274, // [outline] action — access, alert, always on, announcement, antenna
    'perm_scan_wifi_rounded':
        0xf0066, // [round] action — access, alert, always on, announcement, antenna
    'perm_scan_wifi_sharp':
        0xeb87, // [sharp] action — access, alert, always on, announcement, antenna
    'person':
        0xe491, // social — account, avatar, avatar filled, avatar outline, body
    'person_2': 0xf0870, // social — abstract, account, avatar, body, circle
    'person_2_outlined':
        0xf08ae, // [outline] social — abstract, account, avatar, body, circle
    'person_2_rounded':
        0xf0890, // [round] social — abstract, account, avatar, body, circle
    'person_2_sharp':
        0xf0847, // [sharp] social — abstract, account, avatar, body, circle
    'person_3':
        0xf0871, // social — account, association, audience, avatar, collaboration
    'person_3_outlined':
        0xf08af, // [outline] social — account, association, audience, avatar, collaboration
    'person_3_rounded':
        0xf0891, // [round] social — account, association, audience, avatar, collaboration
    'person_3_sharp':
        0xf0848, // [sharp] social — account, association, audience, avatar, collaboration
    'person_4':
        0xf0872, // social — account, account settings, anonymous, avatar, contact
    'person_4_outlined':
        0xf08b0, // [outline] social — account, account settings, anonymous, avatar, contact
    'person_4_rounded':
        0xf0892, // [round] social — account, account settings, anonymous, avatar, contact
    'person_4_sharp':
        0xf0849, // [sharp] social — account, account settings, anonymous, avatar, contact
    'person_add':
        0xe492, // social — +, account, account outline, add, add contact
    'person_add_alt':
        0xe493, // social — +, account, account outline, add, add contact
    'person_add_alt_1': 0xe494, // social
    'person_add_alt_1_outlined': 0xf275, // [outline] social
    'person_add_alt_1_rounded': 0xf0067, // [round] social
    'person_add_alt_1_sharp': 0xeb88, // [sharp] social
    'person_add_alt_outlined':
        0xf276, // [outline] social — +, account, account outline, add, add contact
    'person_add_alt_rounded':
        0xf0068, // [round] social — +, account, account outline, add, add contact
    'person_add_alt_sharp':
        0xeb89, // [sharp] social — +, account, account outline, add, add contact
    'person_add_disabled':
        0xe495, // communication — +, account, add, blocked, cancelled
    'person_add_disabled_outlined':
        0xf277, // [outline] communication — +, account, add, blocked, cancelled
    'person_add_disabled_rounded':
        0xf0069, // [round] communication — +, account, add, blocked, cancelled
    'person_add_disabled_sharp':
        0xeb8a, // [sharp] communication — +, account, add, blocked, cancelled
    'person_add_outlined':
        0xf278, // [outline] social — +, account, account outline, add, add contact
    'person_add_rounded':
        0xf006a, // [round] social — +, account, account outline, add, add contact
    'person_add_sharp':
        0xeb8b, // [sharp] social — +, account, account outline, add, add contact
    'person_off':
        0xe496, // social — access denied, account, avatar, block, circle
    'person_off_outlined':
        0xf279, // [outline] social — access denied, account, avatar, block, circle
    'person_off_rounded':
        0xf006b, // [round] social — access denied, account, avatar, block, circle
    'person_off_sharp':
        0xeb8c, // [sharp] social — access denied, account, avatar, block, circle
    'person_outline':
        0xe497, // social — account, avatar, avatar filled, avatar outline, body
    'person_outline_outlined':
        0xf27a, // [outline] social — account, avatar, avatar filled, avatar outline, body
    'person_outline_rounded':
        0xf006c, // [round] social — account, avatar, avatar filled, avatar outline, body
    'person_outline_sharp':
        0xeb8d, // [sharp] social — account, avatar, avatar filled, avatar outline, body
    'person_outlined':
        0xf27b, // [outline] social — account, avatar, avatar filled, avatar outline, body
    'person_pin': 0xe498, // maps — account, address, avatar, circle, colleague
    'person_pin_circle':
        0xe499, // maps — account, address, avatar, circle, client
    'person_pin_circle_outlined':
        0xf27c, // [outline] maps — account, address, avatar, circle, client
    'person_pin_circle_rounded':
        0xf006d, // [round] maps — account, address, avatar, circle, client
    'person_pin_circle_sharp':
        0xeb8e, // [sharp] maps — account, address, avatar, circle, client
    'person_pin_outlined':
        0xf27d, // [outline] maps — account, address, avatar, circle, colleague
    'person_pin_rounded':
        0xf006e, // [round] maps — account, address, avatar, circle, colleague
    'person_pin_sharp':
        0xeb8f, // [sharp] maps — account, address, avatar, circle, colleague
    'person_remove': 0xe49a, // social — account, avatar, ban, blacklist, block
    'person_remove_alt_1': 0xe49b, // social
    'person_remove_alt_1_outlined': 0xf27e, // [outline] social
    'person_remove_alt_1_rounded': 0xf006f, // [round] social
    'person_remove_alt_1_sharp': 0xeb90, // [sharp] social
    'person_remove_outlined':
        0xf27f, // [outline] social — account, avatar, ban, blacklist, block
    'person_remove_rounded':
        0xf0070, // [round] social — account, avatar, ban, blacklist, block
    'person_remove_sharp':
        0xeb91, // [sharp] social — account, avatar, ban, blacklist, block
    'person_rounded':
        0xf0071, // [round] social — account, avatar, avatar filled, avatar outline, body
    'person_search':
        0xe49c, // communication — account, avatar, body, circle, contact
    'person_search_outlined':
        0xf280, // [outline] communication — account, avatar, body, circle, contact
    'person_search_rounded':
        0xf0072, // [round] communication — account, avatar, body, circle, contact
    'person_search_sharp':
        0xeb92, // [sharp] communication — account, avatar, body, circle, contact
    'person_sharp':
        0xeb93, // [sharp] social — account, avatar, avatar filled, avatar outline, body
    'personal_injury':
        0xe49d, // social — accident, accident claim, aid, anatomy, arm
    'personal_injury_outlined':
        0xf281, // [outline] social — accident, accident claim, aid, anatomy, arm
    'personal_injury_rounded':
        0xf0073, // [round] social — accident, accident claim, aid, anatomy, arm
    'personal_injury_sharp':
        0xeb94, // [sharp] social — accident, accident claim, aid, anatomy, arm
    'personal_video':
        0xe49e, // notification — Android, OS, cam, chrome, desktop
    'personal_video_outlined':
        0xf282, // [outline] notification — Android, OS, cam, chrome, desktop
    'personal_video_rounded':
        0xf0074, // [round] notification — Android, OS, cam, chrome, desktop
    'personal_video_sharp':
        0xeb95, // [sharp] notification — Android, OS, cam, chrome, desktop
    'pest_control': 0xe49f, // maps — alert, animal, block, bug, circle
    'pest_control_outlined':
        0xf283, // [outline] maps — alert, animal, block, bug, circle
    'pest_control_rodent':
        0xe4a0, // maps — animal, animal control, creature, extermination, exterminator
    'pest_control_rodent_outlined':
        0xf284, // [outline] maps — animal, animal control, creature, extermination, exterminator
    'pest_control_rodent_rounded':
        0xf0075, // [round] maps — animal, animal control, creature, extermination, exterminator
    'pest_control_rodent_sharp':
        0xeb96, // [sharp] maps — animal, animal control, creature, extermination, exterminator
    'pest_control_rounded':
        0xf0076, // [round] maps — alert, animal, block, bug, circle
    'pest_control_sharp':
        0xeb97, // [sharp] maps — alert, animal, block, bug, circle
    'pets':
        0xe4a1, // action — adoption, animal, animal foot, animal print, animal shelter
    'pets_outlined':
        0xf285, // [outline] action — adoption, animal, animal foot, animal print, animal shelter
    'pets_rounded':
        0xf0077, // [round] action — adoption, animal, animal foot, animal print, animal shelter
    'pets_sharp':
        0xeb98, // [sharp] action — adoption, animal, animal foot, animal print, animal shelter
    'phishing': 0xf0548, // device — alert, attack, block, caution, crime
    'phishing_outlined':
        0xf0640, // [outline] device — alert, attack, block, caution, crime
    'phishing_rounded':
        0xf035f, // [round] device — alert, attack, block, caution, crime
    'phishing_sharp':
        0xf0452, // [sharp] device — alert, attack, block, caution, crime
    'phone':
        0xe4a2, // communication — audio, business, call, cell, communication
    'phone_android': 0xe4a3, // hardware — OS, android, call, cell, cellphone
    'phone_android_outlined':
        0xf286, // [outline] hardware — OS, android, call, cell, cellphone
    'phone_android_rounded':
        0xf0078, // [round] hardware — OS, android, call, cell, cellphone
    'phone_android_sharp':
        0xeb99, // [sharp] hardware — OS, android, call, cell, cellphone
    'phone_bluetooth_speaker':
        0xe4a4, // notification — audio, audio connection, audio device, bluetooth, bluetooth device
    'phone_bluetooth_speaker_outlined':
        0xf287, // [outline] notification — audio, audio connection, audio device, bluetooth, bluetooth device
    'phone_bluetooth_speaker_rounded':
        0xf0079, // [round] notification — audio, audio connection, audio device, bluetooth, bluetooth device
    'phone_bluetooth_speaker_sharp':
        0xeb9a, // [sharp] notification — audio, audio connection, audio device, bluetooth, bluetooth device
    'phone_callback':
        0xe4a5, // notification — arrow, audio, call, callback, cell
    'phone_callback_outlined':
        0xf288, // [outline] notification — arrow, audio, call, callback, cell
    'phone_callback_rounded':
        0xf007a, // [round] notification — arrow, audio, call, callback, cell
    'phone_callback_sharp':
        0xeb9b, // [sharp] notification — arrow, audio, call, callback, cell
    'phone_disabled':
        0xe4a6, // communication — blocked, call, cancel, cell, communication
    'phone_disabled_outlined':
        0xf289, // [outline] communication — blocked, call, cancel, cell, communication
    'phone_disabled_rounded':
        0xf007b, // [round] communication — blocked, call, cancel, cell, communication
    'phone_disabled_sharp':
        0xeb9c, // [sharp] communication — blocked, call, cancel, cell, communication
    'phone_enabled':
        0xe4a7, // communication — active, answer, audio, available, call
    'phone_enabled_outlined':
        0xf28a, // [outline] communication — active, answer, audio, available, call
    'phone_enabled_rounded':
        0xf007c, // [round] communication — active, answer, audio, available, call
    'phone_enabled_sharp':
        0xeb9d, // [sharp] communication — active, answer, audio, available, call
    'phone_forwarded': 0xe4a8, // notification — angle, arrow, audio, call, cell
    'phone_forwarded_outlined':
        0xf28b, // [outline] notification — angle, arrow, audio, call, cell
    'phone_forwarded_rounded':
        0xf007d, // [round] notification — angle, arrow, audio, call, cell
    'phone_forwarded_sharp':
        0xeb9e, // [sharp] notification — angle, arrow, audio, call, cell
    'phone_in_talk':
        0xe4a9, // Communicate — active call, audio, call, call in progress, calling
    'phone_in_talk_outlined':
        0xf28c, // [outline] Communicate — active call, audio, call, call in progress, calling
    'phone_in_talk_rounded':
        0xf007e, // [round] Communicate — active call, audio, call, call in progress, calling
    'phone_in_talk_sharp':
        0xeb9f, // [sharp] Communicate — active call, audio, call, call in progress, calling
    'phone_iphone': 0xe4aa, // hardware — Android, OS, call, cell, cellphone
    'phone_iphone_outlined':
        0xf28d, // [outline] hardware — Android, OS, call, cell, cellphone
    'phone_iphone_rounded':
        0xf007f, // [round] hardware — Android, OS, call, cell, cellphone
    'phone_iphone_sharp':
        0xeba0, // [sharp] hardware — Android, OS, call, cell, cellphone
    'phone_locked':
        0xe4ab, // notification — access, authentication, authorization, block, call
    'phone_locked_outlined':
        0xf28e, // [outline] notification — access, authentication, authorization, block, call
    'phone_locked_rounded':
        0xf0080, // [round] notification — access, authentication, authorization, block, call
    'phone_locked_sharp':
        0xeba1, // [sharp] notification — access, authentication, authorization, block, call
    'phone_missed':
        0xe4ac, // notification — alert, arrow, call, cell, communication
    'phone_missed_outlined':
        0xf28f, // [outline] notification — alert, arrow, call, cell, communication
    'phone_missed_rounded':
        0xf0081, // [round] notification — alert, arrow, call, cell, communication
    'phone_missed_sharp':
        0xeba2, // [sharp] notification — alert, arrow, call, cell, communication
    'phone_outlined':
        0xf290, // [outline] communication — audio, business, call, cell, communication
    'phone_paused':
        0xe4ad, // notification — break, call, cell, communication, contact
    'phone_paused_outlined':
        0xf291, // [outline] notification — break, call, cell, communication, contact
    'phone_paused_rounded':
        0xf0082, // [round] notification — break, call, cell, communication, contact
    'phone_paused_sharp':
        0xeba3, // [sharp] notification — break, call, cell, communication, contact
    'phone_rounded':
        0xf0083, // [round] communication — audio, business, call, cell, communication
    'phone_sharp':
        0xeba4, // [sharp] communication — audio, business, call, cell, communication
    'phonelink': 0xe4ae, // hardware — Android, OS, cast, chrome, communication
    'phonelink_erase':
        0xe4af, // communication — Android, OS, cancel, cell, clear
    'phonelink_erase_outlined':
        0xf292, // [outline] communication — Android, OS, cancel, cell, clear
    'phonelink_erase_rounded':
        0xf0084, // [round] communication — Android, OS, cancel, cell, clear
    'phonelink_erase_sharp':
        0xeba5, // [sharp] communication — Android, OS, cancel, cell, clear
    'phonelink_lock':
        0xe4b0, // communication — Android, OS, access, access control, authentication
    'phonelink_lock_outlined':
        0xf293, // [outline] communication — Android, OS, access, access control, authentication
    'phonelink_lock_rounded':
        0xf0085, // [round] communication — Android, OS, access, access control, authentication
    'phonelink_lock_sharp':
        0xeba6, // [sharp] communication — Android, OS, access, access control, authentication
    'phonelink_off':
        0xe4b1, // hardware — Android, OS, broken link, cancelled, computer
    'phonelink_off_outlined':
        0xf294, // [outline] hardware — Android, OS, broken link, cancelled, computer
    'phonelink_off_rounded':
        0xf0086, // [round] hardware — Android, OS, broken link, cancelled, computer
    'phonelink_off_sharp':
        0xeba7, // [sharp] hardware — Android, OS, broken link, cancelled, computer
    'phonelink_outlined':
        0xf295, // [outline] hardware — Android, OS, cast, chrome, communication
    'phonelink_ring':
        0xe4b2, // communication — Android, OS, alarm, alert, audio
    'phonelink_ring_outlined':
        0xf296, // [outline] communication — Android, OS, alarm, alert, audio
    'phonelink_ring_rounded':
        0xf0087, // [round] communication — Android, OS, alarm, alert, audio
    'phonelink_ring_sharp':
        0xeba8, // [sharp] communication — Android, OS, alarm, alert, audio
    'phonelink_rounded':
        0xf0088, // [round] hardware — Android, OS, cast, chrome, communication
    'phonelink_setup':
        0xe4b3, // communication — Android, OS, adjust, administration, call
    'phonelink_setup_outlined':
        0xf297, // [outline] communication — Android, OS, adjust, administration, call
    'phonelink_setup_rounded':
        0xf0089, // [round] communication — Android, OS, adjust, administration, call
    'phonelink_setup_sharp':
        0xeba9, // [sharp] communication — Android, OS, adjust, administration, call
    'phonelink_sharp':
        0xebaa, // [sharp] hardware — Android, OS, cast, chrome, communication
    'photo': 0xe4b4, // image — ad, advertising, artwork, attachment, banner
    'photo_album':
        0xe4b5, // image — album, archive, bookmark, browsing, collection of photos
    'photo_album_outlined':
        0xf298, // [outline] image — album, archive, bookmark, browsing, collection of photos
    'photo_album_rounded':
        0xf008a, // [round] image — album, archive, bookmark, browsing, collection of photos
    'photo_album_sharp':
        0xebab, // [sharp] image — album, archive, bookmark, browsing, collection of photos
    'photo_camera': 0xe4b6, // image — analog, camera, capture, circle, device
    'photo_camera_back':
        0xe4b7, // image — back, back camera, camera, capture, circle
    'photo_camera_back_outlined':
        0xf299, // [outline] image — back, back camera, camera, capture, circle
    'photo_camera_back_rounded':
        0xf008b, // [round] image — back, back camera, camera, capture, circle
    'photo_camera_back_sharp':
        0xebac, // [sharp] image — back, back camera, camera, capture, circle
    'photo_camera_front':
        0xe4b8, // image — account, camera, capture, circle, create
    'photo_camera_front_outlined':
        0xf29a, // [outline] image — account, camera, capture, circle, create
    'photo_camera_front_rounded':
        0xf008c, // [round] image — account, camera, capture, circle, create
    'photo_camera_front_sharp':
        0xebad, // [sharp] image — account, camera, capture, circle, create
    'photo_camera_outlined':
        0xf29b, // [outline] image — analog, camera, capture, circle, device
    'photo_camera_rounded':
        0xf008d, // [round] image — analog, camera, capture, circle, device
    'photo_camera_sharp':
        0xebae, // [sharp] image — analog, camera, capture, circle, device
    'photo_filter':
        0xe4b9, // image — adjust, adjust image, adjust photo, ai, artificial
    'photo_filter_outlined':
        0xf29c, // [outline] image — adjust, adjust image, adjust photo, ai, artificial
    'photo_filter_rounded':
        0xf008e, // [round] image — adjust, adjust image, adjust photo, ai, artificial
    'photo_filter_sharp':
        0xebaf, // [sharp] image — adjust, adjust image, adjust photo, ai, artificial
    'photo_library': 0xe4ba, // image — album, archive, assets, browse, catalog
    'photo_library_outlined':
        0xf29d, // [outline] image — album, archive, assets, browse, catalog
    'photo_library_rounded':
        0xf008f, // [round] image — album, archive, assets, browse, catalog
    'photo_library_sharp':
        0xebb0, // [sharp] image — album, archive, assets, browse, catalog
    'photo_outlined':
        0xf29e, // [outline] image — ad, advertising, artwork, attachment, banner
    'photo_rounded':
        0xf0090, // [round] image — ad, advertising, artwork, attachment, banner
    'photo_sharp':
        0xebb1, // [sharp] image — ad, advertising, artwork, attachment, banner
    'photo_size_select_actual':
        0xe4bb, // image — actual, ad, advertising, artwork, attachment
    'photo_size_select_actual_outlined':
        0xf29f, // [outline] image — actual, ad, advertising, artwork, attachment
    'photo_size_select_actual_rounded':
        0xf0091, // [round] image — actual, ad, advertising, artwork, attachment
    'photo_size_select_actual_sharp':
        0xebb2, // [sharp] image — actual, ad, advertising, artwork, attachment
    'photo_size_select_large':
        0xe4bc, // image — adjust, adjustments, album, bigger, dash
    'photo_size_select_large_outlined':
        0xf2a0, // [outline] image — adjust, adjustments, album, bigger, dash
    'photo_size_select_large_rounded':
        0xf0092, // [round] image — adjust, adjustments, album, bigger, dash
    'photo_size_select_large_sharp':
        0xebb3, // [sharp] image — adjust, adjustments, album, bigger, dash
    'photo_size_select_small':
        0xe4bd, // image — adjust, album, arrangement, compact, condense
    'photo_size_select_small_outlined':
        0xf2a1, // [outline] image — adjust, album, arrangement, compact, condense
    'photo_size_select_small_rounded':
        0xf0093, // [round] image — adjust, album, arrangement, compact, condense
    'photo_size_select_small_sharp':
        0xebb4, // [sharp] image — adjust, album, arrangement, compact, condense
    'php': 0xf0549, // action — abstract, alphabet, backend, badge, brackets
    'php_outlined':
        0xf0641, // [outline] action — abstract, alphabet, backend, badge, brackets
    'php_rounded':
        0xf0360, // [round] action — abstract, alphabet, backend, badge, brackets
    'php_sharp':
        0xf0453, // [sharp] action — abstract, alphabet, backend, badge, brackets
    'piano': 0xe4be, // social — art, audio, band, black keys, classical music
    'piano_off':
        0xe4bf, // social — audio, audio settings, crossed out, deactivated, diagonal line
    'piano_off_outlined':
        0xf2a2, // [outline] social — audio, audio settings, crossed out, deactivated, diagonal line
    'piano_off_rounded':
        0xf0094, // [round] social — audio, audio settings, crossed out, deactivated, diagonal line
    'piano_off_sharp':
        0xebb5, // [sharp] social — audio, audio settings, crossed out, deactivated, diagonal line
    'piano_outlined':
        0xf2a3, // [outline] social — art, audio, band, black keys, classical music
    'piano_rounded':
        0xf0095, // [round] social — art, audio, band, black keys, classical music
    'piano_sharp':
        0xebb6, // [sharp] social — art, audio, band, black keys, classical music
    'picture_as_pdf':
        0xe4c0, // image — adobe, adobe acrobat, alphabet, as, character
    'picture_as_pdf_outlined':
        0xf2a4, // [outline] image — adobe, adobe acrobat, alphabet, as, character
    'picture_as_pdf_rounded':
        0xf0096, // [round] image — adobe, adobe acrobat, alphabet, as, character
    'picture_as_pdf_sharp':
        0xebb7, // [sharp] image — adobe, adobe acrobat, alphabet, as, character
    'picture_in_picture':
        0xe4c1, // action — chat, crop, cropped, display, display within display
    'picture_in_picture_alt':
        0xe4c2, // action — alternate, box, chat, crop, cropped
    'picture_in_picture_alt_outlined':
        0xf2a5, // [outline] action — alternate, box, chat, crop, cropped
    'picture_in_picture_alt_rounded':
        0xf0097, // [round] action — alternate, box, chat, crop, cropped
    'picture_in_picture_alt_sharp':
        0xebb8, // [sharp] action — alternate, box, chat, crop, cropped
    'picture_in_picture_outlined':
        0xf2a6, // [outline] action — chat, crop, cropped, display, display within display
    'picture_in_picture_rounded':
        0xf0098, // [round] action — chat, crop, cropped, display, display within display
    'picture_in_picture_sharp':
        0xebb9, // [sharp] action — chat, crop, cropped, display, display within display
    'pie_chart': 0xe4c3, // editor — analysis, analytics, bar, bars, business
    'pie_chart_outline':
        0xe4c5, // editor — analysis, analytics, bar, bars, business
    'pie_chart_outline_outlined':
        0xf2a7, // [outline] editor — analysis, analytics, bar, bars, business
    'pie_chart_outline_rounded':
        0xf0099, // [round] editor — analysis, analytics, bar, bars, business
    'pie_chart_outline_sharp':
        0xebba, // [sharp] editor — analysis, analytics, bar, bars, business
    'pie_chart_rounded':
        0xf009a, // [round] editor — analysis, analytics, bar, bars, business
    'pie_chart_sharp':
        0xebbb, // [sharp] editor — analysis, analytics, bar, bars, business
    'pin': 0xe4c6, // device — 1, 2, 3, address, cartography
    'pin_drop':
        0xe4c7, // maps — address, area, coordinate, current location, destination
    'pin_drop_outlined':
        0xf2a9, // [outline] maps — address, area, coordinate, current location, destination
    'pin_drop_rounded':
        0xf009b, // [round] maps — address, area, coordinate, current location, destination
    'pin_drop_sharp':
        0xebbc, // [sharp] maps — address, area, coordinate, current location, destination
    'pin_end': 0xf054b, // action — arrow, destination, direction, dot, end
    'pin_end_outlined':
        0xf0642, // [outline] action — arrow, destination, direction, dot, end
    'pin_end_rounded':
        0xf0361, // [round] action — arrow, destination, direction, dot, end
    'pin_end_sharp':
        0xf0454, // [sharp] action — arrow, destination, direction, dot, end
    'pin_invoke':
        0xf054c, // action — add location, arrow, destination, direction, dot
    'pin_invoke_outlined':
        0xf0643, // [outline] action — add location, arrow, destination, direction, dot
    'pin_invoke_rounded':
        0xf0362, // [round] action — add location, arrow, destination, direction, dot
    'pin_invoke_sharp':
        0xf0455, // [sharp] action — add location, arrow, destination, direction, dot
    'pin_outlined': 0xf2aa, // [outline] device — 1, 2, 3, address, cartography
    'pin_rounded': 0xf009c, // [round] device — 1, 2, 3, address, cartography
    'pin_sharp': 0xebbd, // [sharp] device — 1, 2, 3, address, cartography
    'pinch': 0xf054d, // action — adjust, arrow, arrows, compress, direction
    'pinch_outlined':
        0xf0644, // [outline] action — adjust, arrow, arrows, compress, direction
    'pinch_rounded':
        0xf0363, // [round] action — adjust, arrow, arrows, compress, direction
    'pinch_sharp':
        0xf0456, // [sharp] action — adjust, arrow, arrows, compress, direction
    'pivot_table_chart':
        0xe4c8, // navigation — accounting, analysis, analytics, arrow, arrows
    'pivot_table_chart_outlined':
        0xf2ab, // [outline] navigation — accounting, analysis, analytics, arrow, arrows
    'pivot_table_chart_rounded':
        0xf009d, // [round] navigation — accounting, analysis, analytics, arrow, arrows
    'pivot_table_chart_sharp':
        0xebbe, // [sharp] navigation — accounting, analysis, analytics, arrow, arrows
    'pix': 0xf054e, // social — bill, brazil, card, cash, commerce
    'pix_outlined':
        0xf0645, // [outline] social — bill, brazil, card, cash, commerce
    'pix_rounded':
        0xf0364, // [round] social — bill, brazil, card, cash, commerce
    'pix_sharp': 0xf0457, // [sharp] social — bill, brazil, card, cash, commerce
    'place':
        0xe4c9, // maps — address, area, current location, destination, direction
    'place_outlined':
        0xf2ac, // [outline] maps — address, area, current location, destination, direction
    'place_rounded':
        0xf009e, // [round] maps — address, area, current location, destination, direction
    'place_sharp':
        0xebbf, // [sharp] maps — address, area, current location, destination, direction
    'plagiarism': 0xe4ca, // action — academic, alert, caution, check, content
    'plagiarism_outlined':
        0xf2ad, // [outline] action — academic, alert, caution, check, content
    'plagiarism_rounded':
        0xf009f, // [round] action — academic, alert, caution, check, content
    'plagiarism_sharp':
        0xebc0, // [sharp] action — academic, alert, caution, check, content
    'play_arrow': 0xe4cb, // av — arrow, audio, back, begin, cinema
    'play_arrow_outlined':
        0xf2ae, // [outline] av — arrow, audio, back, begin, cinema
    'play_arrow_rounded':
        0xf00a0, // [round] av — arrow, audio, back, begin, cinema
    'play_arrow_sharp':
        0xebc1, // [sharp] av — arrow, audio, back, begin, cinema
    'play_circle': 0xe4cc, // av — arrow, audio, begin, broadcast, circle
    'play_circle_fill': 0xe4cd, // av — arrow, circle, media, music, play
    'play_circle_fill_outlined':
        0xf2af, // [outline] av — arrow, circle, media, music, play
    'play_circle_fill_rounded':
        0xf00a1, // [round] av — arrow, circle, media, music, play
    'play_circle_fill_sharp':
        0xebc2, // [sharp] av — arrow, circle, media, music, play
    'play_circle_filled': 0xe4cd, // av — arrow, circle, media, music, play
    'play_circle_filled_outlined':
        0xf2af, // [outline] av — arrow, circle, media, music, play
    'play_circle_filled_rounded':
        0xf00a1, // [round] av — arrow, circle, media, music, play
    'play_circle_filled_sharp':
        0xebc2, // [sharp] av — arrow, circle, media, music, play
    'play_circle_outline': 0xe4ce, // av — arrow, circle, media, music, play
    'play_circle_outline_outlined':
        0xf2b0, // [outline] av — arrow, circle, media, music, play
    'play_circle_outline_rounded':
        0xf00a2, // [round] av — arrow, circle, media, music, play
    'play_circle_outline_sharp':
        0xebc3, // [sharp] av — arrow, circle, media, music, play
    'play_circle_outlined':
        0xf2b1, // [outline] av — arrow, audio, begin, broadcast, circle
    'play_circle_rounded':
        0xf00a3, // [round] av — arrow, audio, begin, broadcast, circle
    'play_circle_sharp':
        0xebc4, // [sharp] av — arrow, audio, begin, broadcast, circle
    'play_disabled':
        0xe4cf, // av — audio, blocked, cannot play, disabled, enabled
    'play_disabled_outlined':
        0xf2b2, // [outline] av — audio, blocked, cannot play, disabled, enabled
    'play_disabled_rounded':
        0xf00a4, // [round] av — audio, blocked, cannot play, disabled, enabled
    'play_disabled_sharp':
        0xebc5, // [sharp] av — audio, blocked, cannot play, disabled, enabled
    'play_for_work': 0xe4d0, // action — arrow, audio, bag, briefcase, business
    'play_for_work_outlined':
        0xf2b3, // [outline] action — arrow, audio, bag, briefcase, business
    'play_for_work_rounded':
        0xf00a5, // [round] action — arrow, audio, bag, briefcase, business
    'play_for_work_sharp':
        0xebc6, // [sharp] action — arrow, audio, bag, briefcase, business
    'play_lesson': 0xe4d1, // device — academic, audio, book, bookmark, class
    'play_lesson_outlined':
        0xf2b4, // [outline] device — academic, audio, book, bookmark, class
    'play_lesson_rounded':
        0xf00a6, // [round] device — academic, audio, book, bookmark, class
    'play_lesson_sharp':
        0xebc7, // [sharp] device — academic, audio, book, bookmark, class
    'playlist_add': 0xe4d2, // av — +, add, add to playlist, audio, audio list
    'playlist_add_check': 0xe4d3, // av — add, added, and, approve, arrangement
    'playlist_add_check_circle':
        0xf054f, // av — accepted, add, album, appended, artist
    'playlist_add_check_circle_outlined':
        0xf0646, // [outline] av — accepted, add, album, appended, artist
    'playlist_add_check_circle_rounded':
        0xf0365, // [round] av — accepted, add, album, appended, artist
    'playlist_add_check_circle_sharp':
        0xf0458, // [sharp] av — accepted, add, album, appended, artist
    'playlist_add_check_outlined':
        0xf2b5, // [outline] av — add, added, and, approve, arrangement
    'playlist_add_check_rounded':
        0xf00a7, // [round] av — add, added, and, approve, arrangement
    'playlist_add_check_sharp':
        0xebc8, // [sharp] av — add, added, and, approve, arrangement
    'playlist_add_circle': 0xf0550, // av — add, album, and, artist, audio
    'playlist_add_circle_outlined':
        0xf0647, // [outline] av — add, album, and, artist, audio
    'playlist_add_circle_rounded':
        0xf0366, // [round] av — add, album, and, artist, audio
    'playlist_add_circle_sharp':
        0xf0459, // [sharp] av — add, album, and, artist, audio
    'playlist_add_outlined':
        0xf2b6, // [outline] av — +, add, add to playlist, audio, audio list
    'playlist_add_rounded':
        0xf00a8, // [round] av — +, add, add to playlist, audio, audio list
    'playlist_add_sharp':
        0xebc9, // [sharp] av — +, add, add to playlist, audio, audio list
    'playlist_play': 0xe4d4, // av — albums, arrow, audio, bars, content
    'playlist_play_outlined':
        0xf2b7, // [outline] av — albums, arrow, audio, bars, content
    'playlist_play_rounded':
        0xf00a9, // [round] av — albums, arrow, audio, bars, content
    'playlist_play_sharp':
        0xebca, // [sharp] av — albums, arrow, audio, bars, content
    'playlist_remove': 0xf0551, // av — -, album, cancel, clear, close
    'playlist_remove_outlined':
        0xf0648, // [outline] av — -, album, cancel, clear, close
    'playlist_remove_rounded':
        0xf0367, // [round] av — -, album, cancel, clear, close
    'playlist_remove_sharp':
        0xf045a, // [sharp] av — -, album, cancel, clear, close
    'plumbing':
        0xe4d5, // maps — build, commercial, connections, construction, diagram
    'plumbing_outlined':
        0xf2b8, // [outline] maps — build, commercial, connections, construction, diagram
    'plumbing_rounded':
        0xf00aa, // [round] maps — build, commercial, connections, construction, diagram
    'plumbing_sharp':
        0xebcb, // [sharp] maps — build, commercial, connections, construction, diagram
    'plus_one':
        0xe4d6, // social — 1, add, adjustment, arithmetic, camera setting
    'plus_one_outlined':
        0xf2b9, // [outline] social — 1, add, adjustment, arithmetic, camera setting
    'plus_one_rounded':
        0xf00ab, // [round] social — 1, add, adjustment, arithmetic, camera setting
    'plus_one_sharp':
        0xebcc, // [sharp] social — 1, add, adjustment, arithmetic, camera setting
    'podcasts':
        0xe4d7, // search — audio, audio player, bars, broadcast, casting
    'podcasts_outlined':
        0xf2ba, // [outline] search — audio, audio player, bars, broadcast, casting
    'podcasts_rounded':
        0xf00ac, // [round] search — audio, audio player, bars, broadcast, casting
    'podcasts_sharp':
        0xebcd, // [sharp] search — audio, audio player, bars, broadcast, casting
    'point_of_sale':
        0xe4d8, // hardware — accounting, business, buy, buying, cash
    'point_of_sale_outlined':
        0xf2bb, // [outline] hardware — accounting, business, buy, buying, cash
    'point_of_sale_rounded':
        0xf00ad, // [round] hardware — accounting, business, buy, buying, cash
    'point_of_sale_sharp':
        0xebce, // [sharp] hardware — accounting, business, buy, buying, cash
    'policy':
        0xe4d9, // content — administration, agreement, certified, checklist, compliance
    'policy_outlined':
        0xf2bc, // [outline] content — administration, agreement, certified, checklist, compliance
    'policy_rounded':
        0xf00ae, // [round] content — administration, agreement, certified, checklist, compliance
    'policy_sharp':
        0xebcf, // [sharp] content — administration, agreement, certified, checklist, compliance
    'poll': 0xe4da, // social — analysis, analytics, assessment, bar, bar chart
    'poll_outlined':
        0xf2bd, // [outline] social — analysis, analytics, assessment, bar, bar chart
    'poll_rounded':
        0xf00af, // [round] social — analysis, analytics, assessment, bar, bar chart
    'poll_sharp':
        0xebd0, // [sharp] social — analysis, analytics, assessment, bar, bar chart
    'polyline':
        0xf0552, // editor — chart, compose, connect, connected, connection
    'polyline_outlined':
        0xf0649, // [outline] editor — chart, compose, connect, connected, connection
    'polyline_rounded':
        0xf0368, // [round] editor — chart, compose, connect, connected, connection
    'polyline_sharp':
        0xf045b, // [sharp] editor — chart, compose, connect, connected, connection
    'polymer':
        0xe4db, // action — abstract, arrangement, atoms, branching, chain
    'polymer_outlined':
        0xf2be, // [outline] action — abstract, arrangement, atoms, branching, chain
    'polymer_rounded':
        0xf00b0, // [round] action — abstract, arrangement, atoms, branching, chain
    'polymer_sharp':
        0xebd1, // [sharp] action — abstract, arrangement, atoms, branching, chain
    'pool': 0xe4dc, // places — activity, aquatic, athlete, athletic, bath
    'pool_outlined':
        0xf2bf, // [outline] places — activity, aquatic, athlete, athletic, bath
    'pool_rounded':
        0xf00b1, // [round] places — activity, aquatic, athlete, athletic, bath
    'pool_sharp':
        0xebd2, // [sharp] places — activity, aquatic, athlete, athletic, bath
    'portable_wifi_off':
        0xe4dd, // communication — connection, connection disabled, connection off, crossed out, data off
    'portable_wifi_off_outlined':
        0xf2c0, // [outline] communication — connection, connection disabled, connection off, crossed out, data off
    'portable_wifi_off_rounded':
        0xf00b2, // [round] communication — connection, connection disabled, connection off, crossed out, data off
    'portable_wifi_off_sharp':
        0xebd3, // [sharp] communication — connection, connection disabled, connection off, crossed out, data off
    'portrait': 0xe4de, // image — account, accounts, avatar, bust, contact
    'portrait_outlined':
        0xf2c1, // [outline] image — account, accounts, avatar, bust, contact
    'portrait_rounded':
        0xf00b3, // [round] image — account, accounts, avatar, bust, contact
    'portrait_sharp':
        0xebd4, // [sharp] image — account, accounts, avatar, bust, contact
    'post_add': 0xe4df, // editor — +, add, add new, add post, adding content
    'post_add_outlined':
        0xf2c2, // [outline] editor — +, add, add new, add post, adding content
    'post_add_rounded':
        0xf00b4, // [round] editor — +, add, add new, add post, adding content
    'post_add_sharp':
        0xebd5, // [sharp] editor — +, add, add new, add post, adding content
    'power': 0xe4e0, // notification — arc, charge, circle, cord, device
    'power_input':
        0xe4e1, // hardware — adapter, amperage, cable, charge, charging
    'power_input_outlined':
        0xf2c3, // [outline] hardware — adapter, amperage, cable, charge, charging
    'power_input_rounded':
        0xf00b5, // [round] hardware — adapter, amperage, cable, charge, charging
    'power_input_sharp':
        0xebd6, // [sharp] hardware — adapter, amperage, cable, charge, charging
    'power_off': 0xe4e2, // notification — charge, circle, close, command, cord
    'power_off_outlined':
        0xf2c4, // [outline] notification — charge, circle, close, command, cord
    'power_off_rounded':
        0xf00b6, // [round] notification — charge, circle, close, command, cord
    'power_off_sharp':
        0xebd7, // [sharp] notification — charge, circle, close, command, cord
    'power_outlined':
        0xf2c5, // [outline] notification — arc, charge, circle, cord, device
    'power_rounded':
        0xf00b7, // [round] notification — arc, charge, circle, cord, device
    'power_settings_new':
        0xe4e3, // action — circle, command, device, electrical, electronics
    'power_settings_new_outlined':
        0xf2c6, // [outline] action — circle, command, device, electrical, electronics
    'power_settings_new_rounded':
        0xf00b8, // [round] action — circle, command, device, electrical, electronics
    'power_settings_new_sharp':
        0xebd8, // [sharp] action — circle, command, device, electrical, electronics
    'power_sharp':
        0xebd9, // [sharp] notification — arc, charge, circle, cord, device
    'precision_manufacturing':
        0xe4e4, // social — accurate, advanced, arm, assembly, assembly line
    'precision_manufacturing_outlined':
        0xf2c7, // [outline] social — accurate, advanced, arm, assembly, assembly line
    'precision_manufacturing_rounded':
        0xf00b9, // [round] social — accurate, advanced, arm, assembly, assembly line
    'precision_manufacturing_sharp':
        0xebda, // [sharp] social — accurate, advanced, arm, assembly, assembly line
    'pregnant_woman': 0xe4e5, // action — abdomen, baby, birth, body, child
    'pregnant_woman_outlined':
        0xf2c8, // [outline] action — abdomen, baby, birth, body, child
    'pregnant_woman_rounded':
        0xf00ba, // [round] action — abdomen, baby, birth, body, child
    'pregnant_woman_sharp':
        0xebdb, // [sharp] action — abdomen, baby, birth, body, child
    'present_to_all':
        0xe4e6, // communication — all, arrow, audience, broadcast, cast
    'present_to_all_outlined':
        0xf2c9, // [outline] communication — all, arrow, audience, broadcast, cast
    'present_to_all_rounded':
        0xf00bb, // [round] communication — all, arrow, audience, broadcast, cast
    'present_to_all_sharp':
        0xebdc, // [sharp] communication — all, arrow, audience, broadcast, cast
    'preview': 0xe4e7, // action — check, design, discern, disclosed, discover
    'preview_outlined':
        0xf2ca, // [outline] action — check, design, discern, disclosed, discover
    'preview_rounded':
        0xf00bc, // [round] action — check, design, discern, disclosed, discover
    'preview_sharp':
        0xebdd, // [sharp] action — check, design, discern, disclosed, discover
    'price_change': 0xe4e8, // device — analysis, arrow, arrows, bill, card
    'price_change_outlined':
        0xf2cb, // [outline] device — analysis, arrow, arrows, bill, card
    'price_change_rounded':
        0xf00bd, // [round] device — analysis, arrow, arrows, bill, card
    'price_change_sharp':
        0xebde, // [sharp] device — analysis, arrow, arrows, bill, card
    'price_check':
        0xe4e9, // device — approve, barcode scanner, bill, card, cash
    'price_check_outlined':
        0xf2cc, // [outline] device — approve, barcode scanner, bill, card, cash
    'price_check_rounded':
        0xf00be, // [round] device — approve, barcode scanner, bill, card, cash
    'price_check_sharp':
        0xebdf, // [sharp] device — approve, barcode scanner, bill, card, cash
    'print': 0xe4ea, // action — copier, copy, device, document, draft
    'print_disabled':
        0xe4eb, // communication — access denied, action denied, blocked, cancelled, cannot print
    'print_disabled_outlined':
        0xf2cd, // [outline] communication — access denied, action denied, blocked, cancelled, cannot print
    'print_disabled_rounded':
        0xf00bf, // [round] communication — access denied, action denied, blocked, cancelled, cannot print
    'print_disabled_sharp':
        0xebe0, // [sharp] communication — access denied, action denied, blocked, cancelled, cannot print
    'print_outlined':
        0xf2ce, // [outline] action — copier, copy, device, document, draft
    'print_rounded':
        0xf00c0, // [round] action — copier, copy, device, document, draft
    'print_sharp':
        0xebe1, // [sharp] action — copier, copy, device, document, draft
    'priority_high':
        0xe4ec, // notification — !, alarm, alert, attention, caution
    'priority_high_outlined':
        0xf2cf, // [outline] notification — !, alarm, alert, attention, caution
    'priority_high_rounded':
        0xf00c1, // [round] notification — !, alarm, alert, attention, caution
    'priority_high_sharp':
        0xebe2, // [sharp] notification — !, alarm, alert, attention, caution
    'privacy_tip':
        0xe4ed, // action — account, advice, alert, announcement, assist
    'privacy_tip_outlined':
        0xf2d0, // [outline] action — account, advice, alert, announcement, assist
    'privacy_tip_rounded':
        0xf00c2, // [round] action — account, advice, alert, announcement, assist
    'privacy_tip_sharp':
        0xebe3, // [sharp] action — account, advice, alert, announcement, assist
    'private_connectivity':
        0xf0553, // action — access, anonymize, connection, connectivity, digital privacy
    'private_connectivity_outlined':
        0xf064a, // [outline] action — access, anonymize, connection, connectivity, digital privacy
    'private_connectivity_rounded':
        0xf0369, // [round] action — access, anonymize, connection, connectivity, digital privacy
    'private_connectivity_sharp':
        0xf045c, // [sharp] action — access, anonymize, connection, connectivity, digital privacy
    'production_quantity_limits':
        0xe4ee, // action — !, alert, amount, attention, bill
    'production_quantity_limits_outlined':
        0xf2d1, // [outline] action — !, alert, amount, attention, bill
    'production_quantity_limits_rounded':
        0xf00c3, // [round] action — !, alert, amount, attention, bill
    'production_quantity_limits_sharp':
        0xebe4, // [sharp] action — !, alert, amount, attention, bill
    'propane': 0xf07b9, // home — barbecue, bottle, cap, container, cooking
    'propane_outlined':
        0xf0709, // [outline] home — barbecue, bottle, cap, container, cooking
    'propane_rounded':
        0xf0811, // [round] home — barbecue, bottle, cap, container, cooking
    'propane_sharp':
        0xf0761, // [sharp] home — barbecue, bottle, cap, container, cooking
    'propane_tank': 0xf07ba, // home — barbecue, bbq, bottle, camping, container
    'propane_tank_outlined':
        0xf070a, // [outline] home — barbecue, bbq, bottle, camping, container
    'propane_tank_rounded':
        0xf0812, // [round] home — barbecue, bbq, bottle, camping, container
    'propane_tank_sharp':
        0xf0762, // [sharp] home — barbecue, bbq, bottle, camping, container
    'psychology':
        0xe4ef, // social — awareness, behavior, body, brain, brainstorm
    'psychology_alt':
        0xf0873, // social — ?, abstract, alternate, analysis, assistance
    'psychology_alt_outlined':
        0xf08b1, // [outline] social — ?, abstract, alternate, analysis, assistance
    'psychology_alt_rounded':
        0xf0893, // [round] social — ?, abstract, alternate, analysis, assistance
    'psychology_alt_sharp':
        0xf084a, // [sharp] social — ?, abstract, alternate, analysis, assistance
    'psychology_outlined':
        0xf2d2, // [outline] social — awareness, behavior, body, brain, brainstorm
    'psychology_rounded':
        0xf00c4, // [round] social — awareness, behavior, body, brain, brainstorm
    'psychology_sharp':
        0xebe5, // [sharp] social — awareness, behavior, body, brain, brainstorm
    'public':
        0xe4f0, // social — access, accessibility, circle, community, connection
    'public_off':
        0xe4f1, // social — access, circle, connection, continents, disabled
    'public_off_outlined':
        0xf2d3, // [outline] social — access, circle, connection, continents, disabled
    'public_off_rounded':
        0xf00c5, // [round] social — access, circle, connection, continents, disabled
    'public_off_sharp':
        0xebe6, // [sharp] social — access, circle, connection, continents, disabled
    'public_outlined':
        0xf2d4, // [outline] social — access, accessibility, circle, community, connection
    'public_rounded':
        0xf00c6, // [round] social — access, accessibility, circle, community, connection
    'public_sharp':
        0xebe7, // [sharp] social — access, accessibility, circle, community, connection
    'publish':
        0xe4f2, // editor — arrow, arrow up, cloud, cloud upload, data transfer
    'publish_outlined':
        0xf2d5, // [outline] editor — arrow, arrow up, cloud, cloud upload, data transfer
    'publish_rounded':
        0xf00c7, // [round] editor — arrow, arrow up, cloud, cloud upload, data transfer
    'publish_sharp':
        0xebe8, // [sharp] editor — arrow, arrow up, cloud, cloud upload, data transfer
    'published_with_changes':
        0xe4f3, // action — approve, approved, arrow, arrows, article
    'published_with_changes_outlined':
        0xf2d6, // [outline] action — approve, approved, arrow, arrows, article
    'published_with_changes_rounded':
        0xf00c8, // [round] action — approve, approved, arrow, arrows, article
    'published_with_changes_sharp':
        0xebe9, // [sharp] action — approve, approved, arrow, arrows, article
    'punch_clock':
        0xf0554, // device — attendance, attendance tracking, business, clock, clock in
    'punch_clock_outlined':
        0xf064b, // [outline] device — attendance, attendance tracking, business, clock, clock in
    'punch_clock_rounded':
        0xf036a, // [round] device — attendance, attendance tracking, business, clock, clock in
    'punch_clock_sharp':
        0xf045d, // [sharp] device — attendance, attendance tracking, business, clock, clock in
    'push_pin': 0xe4f4, // content — anchor, attach, board, bookmark, bulletin
    'push_pin_outlined':
        0xf2d7, // [outline] content — anchor, attach, board, bookmark, bulletin
    'push_pin_rounded':
        0xf00c9, // [round] content — anchor, attach, board, bookmark, bulletin
    'push_pin_sharp':
        0xebea, // [sharp] content — anchor, attach, board, bookmark, bulletin
    'qr_code':
        0xe4f5, // communication — 2d barcode, access, barcode, camera, code
    'qr_code_2':
        0xe4f6, // communication — 2d barcode, barcode, business, camera, code
    'qr_code_2_outlined':
        0xf2d8, // [outline] communication — 2d barcode, barcode, business, camera, code
    'qr_code_2_rounded':
        0xf00ca, // [round] communication — 2d barcode, barcode, business, camera, code
    'qr_code_2_sharp':
        0xebeb, // [sharp] communication — 2d barcode, barcode, business, camera, code
    'qr_code_outlined':
        0xf2d9, // [outline] communication — 2d barcode, access, barcode, camera, code
    'qr_code_rounded':
        0xf00cb, // [round] communication — 2d barcode, access, barcode, camera, code
    'qr_code_scanner':
        0xe4f7, // communication — access, authentication, barcode, bars, camera
    'qr_code_scanner_outlined':
        0xf2da, // [outline] communication — access, authentication, barcode, bars, camera
    'qr_code_scanner_rounded':
        0xf00cc, // [round] communication — access, authentication, barcode, bars, camera
    'qr_code_scanner_sharp':
        0xebec, // [sharp] communication — access, authentication, barcode, bars, camera
    'qr_code_sharp':
        0xebed, // [sharp] communication — 2d barcode, access, barcode, camera, code
    'query_builder':
        0xe4f8, // action — alarm, appointment, builder, calendar, chronometer
    'query_builder_outlined':
        0xf2db, // [outline] action — alarm, appointment, builder, calendar, chronometer
    'query_builder_rounded':
        0xf00cd, // [round] action — alarm, appointment, builder, calendar, chronometer
    'query_builder_sharp':
        0xebee, // [sharp] action — alarm, appointment, builder, calendar, chronometer
    'query_stats':
        0xe4f9, // editor — analysis, analytics, chart, circle, dashboard
    'query_stats_outlined':
        0xf2dc, // [outline] editor — analysis, analytics, chart, circle, dashboard
    'query_stats_rounded':
        0xf00ce, // [round] editor — analysis, analytics, chart, circle, dashboard
    'query_stats_sharp':
        0xebef, // [sharp] editor — analysis, analytics, chart, circle, dashboard
    'question_answer':
        0xe4fa, // action — answer, answers, bubble, chat, comment
    'question_answer_outlined':
        0xf2dd, // [outline] action — answer, answers, bubble, chat, comment
    'question_answer_rounded':
        0xf00cf, // [round] action — answer, answers, bubble, chat, comment
    'question_answer_sharp':
        0xebf0, // [sharp] action — answer, answers, bubble, chat, comment
    'question_mark': 0xf0555, // action — ?, ask, assistance, circle, clue
    'question_mark_outlined':
        0xf064c, // [outline] action — ?, ask, assistance, circle, clue
    'question_mark_rounded':
        0xf036b, // [round] action — ?, ask, assistance, circle, clue
    'question_mark_sharp':
        0xf045e, // [sharp] action — ?, ask, assistance, circle, clue
    'queue': 0xe4fb, // av — add, archive, book, catalog, content
    'queue_music':
        0xe4fc, // av — audio, burger menu, entertainment, lines, list
    'queue_music_outlined':
        0xf2de, // [outline] av — audio, burger menu, entertainment, lines, list
    'queue_music_rounded':
        0xf00d0, // [round] av — audio, burger menu, entertainment, lines, list
    'queue_music_sharp':
        0xebf1, // [sharp] av — audio, burger menu, entertainment, lines, list
    'queue_outlined':
        0xf2df, // [outline] av — add, archive, book, catalog, content
    'queue_play_next':
        0xe4fd, // av — +, add, add to playlist, add to queue, arrow
    'queue_play_next_outlined':
        0xf2e0, // [outline] av — +, add, add to playlist, add to queue, arrow
    'queue_play_next_rounded':
        0xf00d1, // [round] av — +, add, add to playlist, add to queue, arrow
    'queue_play_next_sharp':
        0xebf2, // [sharp] av — +, add, add to playlist, add to queue, arrow
    'queue_rounded':
        0xf00d2, // [round] av — add, archive, book, catalog, content
    'queue_sharp': 0xebf3, // [sharp] av — add, archive, book, catalog, content
    'quick_contacts_dialer': 0xe18c,
    'quick_contacts_dialer_outlined': 0xef7b,
    'quick_contacts_dialer_rounded': 0xf668,
    'quick_contacts_dialer_sharp': 0xe889,
    'quick_contacts_mail': 0xe18a,
    'quick_contacts_mail_outlined': 0xef79,
    'quick_contacts_mail_rounded': 0xf666,
    'quick_contacts_mail_sharp': 0xe887,
    'quickreply':
        0xe4fe, // action — bolt, bubble, chat, comment, comment bubble
    'quickreply_outlined':
        0xf2e1, // [outline] action — bolt, bubble, chat, comment, comment bubble
    'quickreply_rounded':
        0xf00d3, // [round] action — bolt, bubble, chat, comment, comment bubble
    'quickreply_sharp':
        0xebf4, // [sharp] action — bolt, bubble, chat, comment, comment bubble
    'quiz': 0xe4ff, // device — ?, academic, answer, assessment, assistance
    'quiz_outlined':
        0xf2e2, // [outline] device — ?, academic, answer, assessment, assistance
    'quiz_rounded':
        0xf00d4, // [round] device — ?, academic, answer, assessment, assistance
    'quiz_sharp':
        0xebf5, // [sharp] device — ?, academic, answer, assessment, assistance
    'quora': 0xf0556, // brand logo
    'quora_outlined': 0xf064d, // [outline] brand logo
    'quora_rounded': 0xf036c, // [round] brand logo
    'quora_sharp': 0xf045f, // [sharp] brand logo
    'r_mobiledata':
        0xe500, // device — alphabet, bars, cell, cellular, cellular data
    'r_mobiledata_outlined':
        0xf2e3, // [outline] device — alphabet, bars, cell, cellular, cellular data
    'r_mobiledata_rounded':
        0xf00d5, // [round] device — alphabet, bars, cell, cellular, cellular data
    'r_mobiledata_sharp':
        0xebf6, // [sharp] device — alphabet, bars, cell, cellular, cellular data
    'radar': 0xe501, // device — area, broadcast, circle, cone, detect
    'radar_outlined':
        0xf2e4, // [outline] device — area, broadcast, circle, cone, detect
    'radar_rounded':
        0xf00d6, // [round] device — area, broadcast, circle, cone, detect
    'radar_sharp':
        0xebf7, // [sharp] device — area, broadcast, circle, cone, detect
    'radio': 0xe502, // av — airwaves, antenna, audio, broadcast, channel
    'radio_button_checked':
        0xe503, // toggle — active, bullet, checked, checked circle, checked state
    'radio_button_checked_outlined':
        0xf2e5, // [outline] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_checked_rounded':
        0xf00d7, // [round] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_checked_sharp':
        0xebf8, // [sharp] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_off':
        0xe504, // toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_off_outlined':
        0xf2e6, // [outline] toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_off_rounded':
        0xf00d8, // [round] toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_off_sharp':
        0xebf9, // [sharp] toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_on':
        0xe503, // toggle — active, bullet, checked, checked circle, checked state
    'radio_button_on_outlined':
        0xf2e5, // [outline] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_on_rounded':
        0xf00d7, // [round] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_on_sharp':
        0xebf8, // [sharp] toggle — active, bullet, checked, checked circle, checked state
    'radio_button_unchecked':
        0xe504, // toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_unchecked_outlined':
        0xf2e6, // [outline] toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_unchecked_rounded':
        0xf00d8, // [round] toggle — blank radio button, bullet, choice, choose, circle
    'radio_button_unchecked_sharp':
        0xebf9, // [sharp] toggle — blank radio button, bullet, choice, choose, circle
    'radio_outlined':
        0xf2e7, // [outline] av — airwaves, antenna, audio, broadcast, channel
    'radio_rounded':
        0xf00d9, // [round] av — airwaves, antenna, audio, broadcast, channel
    'radio_sharp':
        0xebfa, // [sharp] av — airwaves, antenna, audio, broadcast, channel
    'railway_alert': 0xe505, // maps — !, alert, attention, automobile, bike
    'railway_alert_outlined':
        0xf2e8, // [outline] maps — !, alert, attention, automobile, bike
    'railway_alert_rounded':
        0xf00da, // [round] maps — !, alert, attention, automobile, bike
    'railway_alert_sharp':
        0xebfb, // [sharp] maps — !, alert, attention, automobile, bike
    'ramen_dining':
        0xe506, // maps — asian food, bowl, chinese food, chopsticks, chopsticks in bowl
    'ramen_dining_outlined':
        0xf2e9, // [outline] maps — asian food, bowl, chinese food, chopsticks, chopsticks in bowl
    'ramen_dining_rounded':
        0xf00db, // [round] maps — asian food, bowl, chinese food, chopsticks, chopsticks in bowl
    'ramen_dining_sharp':
        0xebfc, // [sharp] maps — asian food, bowl, chinese food, chopsticks, chopsticks in bowl
    'ramp_left': 0xf0557, // maps — arrow, arrows, curve, diagram, direction
    'ramp_left_outlined':
        0xf064e, // [outline] maps — arrow, arrows, curve, diagram, direction
    'ramp_left_rounded':
        0xf036d, // [round] maps — arrow, arrows, curve, diagram, direction
    'ramp_left_sharp':
        0xf0460, // [sharp] maps — arrow, arrows, curve, diagram, direction
    'ramp_right': 0xf0558, // maps — access, advance, angle, arrow, arrows
    'ramp_right_outlined':
        0xf064f, // [outline] maps — access, advance, angle, arrow, arrows
    'ramp_right_rounded':
        0xf036e, // [round] maps — access, advance, angle, arrow, arrows
    'ramp_right_sharp':
        0xf0461, // [sharp] maps — access, advance, angle, arrow, arrows
    'rate_review':
        0xe507, // maps — assessment, box, bubble, chat bubble, comment
    'rate_review_outlined':
        0xf2ea, // [outline] maps — assessment, box, bubble, chat bubble, comment
    'rate_review_rounded':
        0xf00dc, // [round] maps — assessment, box, bubble, chat bubble, comment
    'rate_review_sharp':
        0xebfd, // [sharp] maps — assessment, box, bubble, chat bubble, comment
    'raw_off': 0xe508, // image — alphabet, camera, cancel, character, close
    'raw_off_outlined':
        0xf2eb, // [outline] image — alphabet, camera, cancel, character, close
    'raw_off_rounded':
        0xf00dd, // [round] image — alphabet, camera, cancel, character, close
    'raw_off_sharp':
        0xebfe, // [sharp] image — alphabet, camera, cancel, character, close
    'raw_on': 0xe509, // image — abstract, activate, active, alphabet, character
    'raw_on_outlined':
        0xf2ec, // [outline] image — abstract, activate, active, alphabet, character
    'raw_on_rounded':
        0xf00de, // [round] image — abstract, activate, active, alphabet, character
    'raw_on_sharp':
        0xebff, // [sharp] image — abstract, activate, active, alphabet, character
    'read_more':
        0xe50a, // communication — add, additional, additional info, arrow, article
    'read_more_outlined':
        0xf2ed, // [outline] communication — add, additional, additional info, arrow, article
    'read_more_rounded':
        0xf00df, // [round] communication — add, additional, additional info, arrow, article
    'read_more_sharp':
        0xec00, // [sharp] communication — add, additional, additional info, arrow, article
    'real_estate_agent':
        0xe50b, // social — advice, agent, agreement, architecture, associate
    'real_estate_agent_outlined':
        0xf2ee, // [outline] social — advice, agent, agreement, architecture, associate
    'real_estate_agent_rounded':
        0xf00e0, // [round] social — advice, agent, agreement, architecture, associate
    'real_estate_agent_sharp':
        0xec01, // [sharp] social — advice, agent, agreement, architecture, associate
    'rebase_edit': 0xf0874, // action — adjust, alter, arrow, arrows, branch
    'receipt': 0xe50c, // action — accounting, bill, cash, check, checkout
    'receipt_long':
        0xe50d, // image — accounting, bill, business, check, checkout
    'receipt_long_outlined':
        0xf2ef, // [outline] image — accounting, bill, business, check, checkout
    'receipt_long_rounded':
        0xf00e1, // [round] image — accounting, bill, business, check, checkout
    'receipt_long_sharp':
        0xec02, // [sharp] image — accounting, bill, business, check, checkout
    'receipt_outlined':
        0xf2f0, // [outline] action — accounting, bill, cash, check, checkout
    'receipt_rounded':
        0xf00e2, // [round] action — accounting, bill, cash, check, checkout
    'receipt_sharp':
        0xec03, // [sharp] action — accounting, bill, cash, check, checkout
    'recent_actors':
        0xe50e, // av — account, accounts, actors, address book, avatar
    'recent_actors_outlined':
        0xf2f1, // [outline] av — account, accounts, actors, address book, avatar
    'recent_actors_rounded':
        0xf00e3, // [round] av — account, accounts, actors, address book, avatar
    'recent_actors_sharp':
        0xec04, // [sharp] av — account, accounts, actors, address book, avatar
    'recommend':
        0xe50f, // social — affirm, agree, agreement, approval, approved
    'recommend_outlined':
        0xf2f2, // [outline] social — affirm, agree, agreement, approval, approved
    'recommend_rounded':
        0xf00e4, // [round] social — affirm, agree, agreement, approval, approved
    'recommend_sharp':
        0xec05, // [sharp] social — affirm, agree, agreement, approval, approved
    'record_voice_over':
        0xe510, // action — account, announce, audio, avatar, broadcast
    'record_voice_over_outlined':
        0xf2f3, // [outline] action — account, announce, audio, avatar, broadcast
    'record_voice_over_rounded':
        0xf00e5, // [round] action — account, announce, audio, avatar, broadcast
    'record_voice_over_sharp':
        0xec06, // [sharp] action — account, announce, audio, avatar, broadcast
    'rectangle':
        0xf0559, // editor — basic shape, blank, box, container, contour
    'rectangle_outlined':
        0xf0650, // [outline] editor — basic shape, blank, box, container, contour
    'rectangle_rounded':
        0xf036f, // [round] editor — basic shape, blank, box, container, contour
    'rectangle_sharp':
        0xf0462, // [sharp] editor — basic shape, blank, box, container, contour
    'recycling':
        0xf055a, // social — arrows, arrows in a loop, bio, circle, conservation
    'recycling_outlined':
        0xf0651, // [outline] social — arrows, arrows in a loop, bio, circle, conservation
    'recycling_rounded':
        0xf0370, // [round] social — arrows, arrows in a loop, bio, circle, conservation
    'recycling_sharp':
        0xf0463, // [sharp] social — arrows, arrows in a loop, bio, circle, conservation
    'reddit': 0xf055b, // brand logo
    'reddit_outlined': 0xf0652, // [outline] brand logo
    'reddit_rounded': 0xf0371, // [round] brand logo
    'reddit_sharp': 0xf0464, // [sharp] brand logo
    'redeem': 0xe511, // action — bill, bonus, bonus points, bow, buy
    'redeem_outlined':
        0xf2f4, // [outline] action — bill, bonus, bonus points, bow, buy
    'redeem_rounded':
        0xf00e6, // [round] action — bill, bonus, bonus points, bow, buy
    'redeem_sharp':
        0xec07, // [sharp] action — bill, bonus, bonus points, bow, buy
    'redo': 0xe512, // content — advancement, again, arrow, backward, clockwise
    'redo_outlined':
        0xf2f5, // [outline] content — advancement, again, arrow, backward, clockwise
    'redo_rounded':
        0xf00e7, // [round] content — advancement, again, arrow, backward, clockwise
    'redo_sharp':
        0xec08, // [sharp] content — advancement, again, arrow, backward, clockwise
    'reduce_capacity':
        0xe513, // social — arrow, body, capacity, capacity reduction, compact
    'reduce_capacity_outlined':
        0xf2f6, // [outline] social — arrow, body, capacity, capacity reduction, compact
    'reduce_capacity_rounded':
        0xf00e8, // [round] social — arrow, body, capacity, capacity reduction, compact
    'reduce_capacity_sharp':
        0xec09, // [sharp] social — arrow, body, capacity, capacity reduction, compact
    'refresh': 0xe514, // navigation — around, arrow, arrows, browser, circular
    'refresh_outlined':
        0xf2f7, // [outline] navigation — around, arrow, arrows, browser, circular
    'refresh_rounded':
        0xf00e9, // [round] navigation — around, arrow, arrows, browser, circular
    'refresh_sharp':
        0xec0a, // [sharp] navigation — around, arrow, arrows, browser, circular
    'remember_me':
        0xe515, // device — Android, OS, account, authentication, avatar
    'remember_me_outlined':
        0xf2f8, // [outline] device — Android, OS, account, authentication, avatar
    'remember_me_rounded':
        0xf00ea, // [round] device — Android, OS, account, authentication, avatar
    'remember_me_sharp':
        0xec0b, // [sharp] device — Android, OS, account, authentication, avatar
    'remove': 0xe516, // content — bar, can, cancel, clean, clear
    'remove_circle': 0xe517, // content — alert, ban, block, can, cancel
    'remove_circle_outline': 0xe518, // content — alert, ban, block, can, cancel
    'remove_circle_outline_outlined':
        0xf2f9, // [outline] content — alert, ban, block, can, cancel
    'remove_circle_outline_rounded':
        0xf00eb, // [round] content — alert, ban, block, can, cancel
    'remove_circle_outline_sharp':
        0xec0c, // [sharp] content — alert, ban, block, can, cancel
    'remove_circle_outlined':
        0xf2fa, // [outline] content — alert, ban, block, can, cancel
    'remove_circle_rounded':
        0xf00ec, // [round] content — alert, ban, block, can, cancel
    'remove_circle_sharp':
        0xec0d, // [sharp] content — alert, ban, block, can, cancel
    'remove_done': 0xe519, // action — abolish, accept, approval, approve, bin
    'remove_done_outlined':
        0xf2fb, // [outline] action — abolish, accept, approval, approve, bin
    'remove_done_rounded':
        0xf00ed, // [round] action — abolish, accept, approval, approve, bin
    'remove_done_sharp':
        0xec0e, // [sharp] action — abolish, accept, approval, approve, bin
    'remove_from_queue': 0xe51a, // av — cancel, clear, close, cross, delete
    'remove_from_queue_outlined':
        0xf2fc, // [outline] av — cancel, clear, close, cross, delete
    'remove_from_queue_rounded':
        0xf00ee, // [round] av — cancel, clear, close, cross, delete
    'remove_from_queue_sharp':
        0xec0f, // [sharp] av — cancel, clear, close, cross, delete
    'remove_moderator':
        0xe51b, // social — access, account, admin, administrator, ban
    'remove_moderator_outlined':
        0xf2fd, // [outline] social — access, account, admin, administrator, ban
    'remove_moderator_rounded':
        0xf00ef, // [round] social — access, account, admin, administrator, ban
    'remove_moderator_sharp':
        0xec10, // [sharp] social — access, account, admin, administrator, ban
    'remove_outlined':
        0xf2fe, // [outline] content — bar, can, cancel, clean, clear
    'remove_red_eye':
        0xe51c, // image — display, eye, glance, hidden, hidden text
    'remove_red_eye_outlined':
        0xf2ff, // [outline] image — display, eye, glance, hidden, hidden text
    'remove_red_eye_rounded':
        0xf00f0, // [round] image — display, eye, glance, hidden, hidden text
    'remove_red_eye_sharp':
        0xec11, // [sharp] image — display, eye, glance, hidden, hidden text
    'remove_road': 0xf07bb, // maps — -, cancel, clear, close, delete
    'remove_road_outlined':
        0xf070b, // [outline] maps — -, cancel, clear, close, delete
    'remove_road_rounded':
        0xf0813, // [round] maps — -, cancel, clear, close, delete
    'remove_road_sharp':
        0xf0763, // [sharp] maps — -, cancel, clear, close, delete
    'remove_rounded':
        0xf00f1, // [round] content — bar, can, cancel, clean, clear
    'remove_sharp': 0xec12, // [sharp] content — bar, can, cancel, clean, clear
    'remove_shopping_cart':
        0xe51d, // action — basket, card, cart, cash, checkout
    'remove_shopping_cart_outlined':
        0xf300, // [outline] action — basket, card, cart, cash, checkout
    'remove_shopping_cart_rounded':
        0xf00f2, // [round] action — basket, card, cart, cash, checkout
    'remove_shopping_cart_sharp':
        0xec13, // [sharp] action — basket, card, cart, cash, checkout
    'reorder': 0xe51e, // action — adjust, arrows, bars, burger, dots
    'reorder_outlined':
        0xf301, // [outline] action — adjust, arrows, bars, burger, dots
    'reorder_rounded':
        0xf00f3, // [round] action — adjust, arrows, bars, burger, dots
    'reorder_sharp':
        0xec14, // [sharp] action — adjust, arrows, bars, burger, dots
    'repartition':
        0xf0875, // action — allocation, analysis, area, arrow, arrows
    'repartition_outlined':
        0xf08b2, // [outline] action — allocation, analysis, area, arrow, arrows
    'repartition_rounded':
        0xf0894, // [round] action — allocation, analysis, area, arrow, arrows
    'repartition_sharp':
        0xf084b, // [sharp] action — allocation, analysis, area, arrow, arrows
    'repeat': 0xe51f, // av — arrow, arrows, audio, circular arrows, continuous
    'repeat_on': 0xe520, // av — active, album, arrow, arrows, audio
    'repeat_on_outlined':
        0xf302, // [outline] av — active, album, arrow, arrows, audio
    'repeat_on_rounded':
        0xf00f4, // [round] av — active, album, arrow, arrows, audio
    'repeat_on_sharp':
        0xec15, // [sharp] av — active, album, arrow, arrows, audio
    'repeat_one': 0xe521, // av — 1, arrow, arrow with number, arrows, audio
    'repeat_one_on': 0xe522, // av — again, album, arrow, arrows, audio
    'repeat_one_on_outlined':
        0xf303, // [outline] av — again, album, arrow, arrows, audio
    'repeat_one_on_rounded':
        0xf00f5, // [round] av — again, album, arrow, arrows, audio
    'repeat_one_on_sharp':
        0xec16, // [sharp] av — again, album, arrow, arrows, audio
    'repeat_one_outlined':
        0xf304, // [outline] av — 1, arrow, arrow with number, arrows, audio
    'repeat_one_rounded':
        0xf00f6, // [round] av — 1, arrow, arrow with number, arrows, audio
    'repeat_one_sharp':
        0xec17, // [sharp] av — 1, arrow, arrow with number, arrows, audio
    'repeat_outlined':
        0xf305, // [outline] av — arrow, arrows, audio, circular arrows, continuous
    'repeat_rounded':
        0xf00f7, // [round] av — arrow, arrows, audio, circular arrows, continuous
    'repeat_sharp':
        0xec18, // [sharp] av — arrow, arrows, audio, circular arrows, continuous
    'replay': 0xe523, // av — again, arrow, arrows, audio, back
    'replay_10': 0xe524, // av — 10, arrow, arrows, audio, back
    'replay_10_outlined':
        0xf306, // [outline] av — 10, arrow, arrows, audio, back
    'replay_10_rounded': 0xf00f8, // [round] av — 10, arrow, arrows, audio, back
    'replay_10_sharp': 0xec19, // [sharp] av — 10, arrow, arrows, audio, back
    'replay_30': 0xe525, // av — 30, arrow, arrows, audio player, back 30
    'replay_30_outlined':
        0xf307, // [outline] av — 30, arrow, arrows, audio player, back 30
    'replay_30_rounded':
        0xf00f9, // [round] av — 30, arrow, arrows, audio player, back 30
    'replay_30_sharp':
        0xec1a, // [sharp] av — 30, arrow, arrows, audio player, back 30
    'replay_5': 0xe526, // av — 5, arrow, arrows, audio player, backward
    'replay_5_outlined':
        0xf308, // [outline] av — 5, arrow, arrows, audio player, backward
    'replay_5_rounded':
        0xf00fa, // [round] av — 5, arrow, arrows, audio player, backward
    'replay_5_sharp':
        0xec1b, // [sharp] av — 5, arrow, arrows, audio player, backward
    'replay_circle_filled':
        0xe527, // av — arrow, arrows, audio player, circle, circular arrow
    'replay_circle_filled_outlined':
        0xf309, // [outline] av — arrow, arrows, audio player, circle, circular arrow
    'replay_circle_filled_rounded':
        0xf00fb, // [round] av — arrow, arrows, audio player, circle, circular arrow
    'replay_circle_filled_sharp':
        0xec1c, // [sharp] av — arrow, arrows, audio player, circle, circular arrow
    'replay_outlined':
        0xf30a, // [outline] av — again, arrow, arrows, audio, back
    'replay_rounded': 0xf00fc, // [round] av — again, arrow, arrows, audio, back
    'replay_sharp': 0xec1d, // [sharp] av — again, arrow, arrows, audio, back
    'reply': 0xe528, // content — arrow, backward, bubble, chat, chat box
    'reply_all': 0xe529, // content — all, answer, arrow, backward, boomerang
    'reply_all_outlined':
        0xf30b, // [outline] content — all, answer, arrow, backward, boomerang
    'reply_all_rounded':
        0xf00fd, // [round] content — all, answer, arrow, backward, boomerang
    'reply_all_sharp':
        0xec1e, // [sharp] content — all, answer, arrow, backward, boomerang
    'reply_outlined':
        0xf30c, // [outline] content — arrow, backward, bubble, chat, chat box
    'reply_rounded':
        0xf00fe, // [round] content — arrow, backward, bubble, chat, chat box
    'reply_sharp':
        0xec1f, // [sharp] content — arrow, backward, bubble, chat, chat box
    'report': 0xe52a, // content — !, abuse, alert, attention, caution
    'report_gmailerrorred':
        0xe52b, // content — !, abuse, alert, attention, caution
    'report_gmailerrorred_outlined':
        0xf30d, // [outline] content — !, abuse, alert, attention, caution
    'report_gmailerrorred_rounded':
        0xf00ff, // [round] content — !, abuse, alert, attention, caution
    'report_gmailerrorred_sharp':
        0xec20, // [sharp] content — !, abuse, alert, attention, caution
    'report_off': 0xe52c, // content — !, alert, attention, block, blocked
    'report_off_outlined':
        0xf30e, // [outline] content — !, alert, attention, block, blocked
    'report_off_rounded':
        0xf0100, // [round] content — !, alert, attention, block, blocked
    'report_off_sharp':
        0xec21, // [sharp] content — !, alert, attention, block, blocked
    'report_outlined':
        0xf30f, // [outline] content — !, abuse, alert, attention, caution
    'report_problem': 0xe52d, // action — !, alert, attention, caution, danger
    'report_problem_outlined':
        0xf310, // [outline] action — !, alert, attention, caution, danger
    'report_problem_rounded':
        0xf0101, // [round] action — !, alert, attention, caution, danger
    'report_problem_sharp':
        0xec22, // [sharp] action — !, alert, attention, caution, danger
    'report_rounded':
        0xf0102, // [round] content — !, abuse, alert, attention, caution
    'report_sharp':
        0xec23, // [sharp] content — !, abuse, alert, attention, caution
    'request_page':
        0xe52e, // action — add, add document, add file, ask, content
    'request_page_outlined':
        0xf311, // [outline] action — add, add document, add file, ask, content
    'request_page_rounded':
        0xf0103, // [round] action — add, add document, add file, ask, content
    'request_page_sharp':
        0xec24, // [sharp] action — add, add document, add file, ask, content
    'request_quote':
        0xe52f, // file — ask for a quote, asking, bill, bubble, business
    'request_quote_outlined':
        0xf312, // [outline] file — ask for a quote, asking, bill, bubble, business
    'request_quote_rounded':
        0xf0104, // [round] file — ask for a quote, asking, bill, bubble, business
    'request_quote_sharp':
        0xec25, // [sharp] file — ask for a quote, asking, bill, bubble, business
    'reset_tv': 0xe530, // device — arrow, arrows, back, circle, circular arrow
    'reset_tv_outlined':
        0xf313, // [outline] device — arrow, arrows, back, circle, circular arrow
    'reset_tv_rounded':
        0xf0105, // [round] device — arrow, arrows, back, circle, circular arrow
    'reset_tv_sharp':
        0xec26, // [sharp] device — arrow, arrows, back, circle, circular arrow
    'restart_alt': 0xe531, // device — alt, around, arrow, begin again, circular
    'restart_alt_outlined':
        0xf314, // [outline] device — alt, around, arrow, begin again, circular
    'restart_alt_rounded':
        0xf0106, // [round] device — alt, around, arrow, begin again, circular
    'restart_alt_sharp':
        0xec27, // [sharp] device — alt, around, arrow, begin again, circular
    'restaurant':
        0xe532, // maps — bar, breakfast, breakfast place, building, cafe
    'restaurant_menu':
        0xe533, // maps — bistro, breakfast, cafe, catering, cuisine
    'restaurant_menu_outlined':
        0xf315, // [outline] maps — bistro, breakfast, cafe, catering, cuisine
    'restaurant_menu_rounded':
        0xf0107, // [round] maps — bistro, breakfast, cafe, catering, cuisine
    'restaurant_menu_sharp':
        0xec28, // [sharp] maps — bistro, breakfast, cafe, catering, cuisine
    'restaurant_outlined':
        0xf316, // [outline] maps — bar, breakfast, breakfast place, building, cafe
    'restaurant_rounded':
        0xf0108, // [round] maps — bar, breakfast, breakfast place, building, cafe
    'restaurant_sharp':
        0xec29, // [sharp] maps — bar, breakfast, breakfast place, building, cafe
    'restore': 0xe534, // action — activity, arrow, back, backup, backwards
    'restore_from_trash':
        0xe535, // action — archive, archive management, arrow, back, backwards
    'restore_from_trash_outlined':
        0xf317, // [outline] action — archive, archive management, arrow, back, backwards
    'restore_from_trash_rounded':
        0xf0109, // [round] action — archive, archive management, arrow, back, backwards
    'restore_from_trash_sharp':
        0xec2a, // [sharp] action — archive, archive management, arrow, back, backwards
    'restore_outlined':
        0xf318, // [outline] action — activity, arrow, back, backup, backwards
    'restore_page':
        0xe536, // action — arrow, arrows, back, browser, circular arrow
    'restore_page_outlined':
        0xf319, // [outline] action — arrow, arrows, back, browser, circular arrow
    'restore_page_rounded':
        0xf010a, // [round] action — arrow, arrows, back, browser, circular arrow
    'restore_page_sharp':
        0xec2b, // [sharp] action — arrow, arrows, back, browser, circular arrow
    'restore_rounded':
        0xf010b, // [round] action — activity, arrow, back, backup, backwards
    'restore_sharp':
        0xec2c, // [sharp] action — activity, arrow, back, backup, backwards
    'reviews': 0xe537, // device — approve, attempt, best, bubble, chat
    'reviews_outlined':
        0xf31a, // [outline] device — approve, attempt, best, bubble, chat
    'reviews_rounded':
        0xf010c, // [round] device — approve, attempt, best, bubble, chat
    'reviews_sharp':
        0xec2d, // [sharp] device — approve, attempt, best, bubble, chat
    'rice_bowl':
        0xe538, // places — asian cuisine, asian food, bowl, breakfast, carbohydrate
    'rice_bowl_outlined':
        0xf31b, // [outline] places — asian cuisine, asian food, bowl, breakfast, carbohydrate
    'rice_bowl_rounded':
        0xf010d, // [round] places — asian cuisine, asian food, bowl, breakfast, carbohydrate
    'rice_bowl_sharp':
        0xec2e, // [sharp] places — asian cuisine, asian food, bowl, breakfast, carbohydrate
    'ring_volume': 0xe539, // communication — adjust, alert, audio, bell, call
    'ring_volume_outlined':
        0xf31c, // [outline] communication — adjust, alert, audio, bell, call
    'ring_volume_rounded':
        0xf010e, // [round] communication — adjust, alert, audio, bell, call
    'ring_volume_sharp':
        0xec2f, // [sharp] communication — adjust, alert, audio, bell, call
    'rocket':
        0xf055c, // action — adventure, ascent, astronaut, astronomy, boost
    'rocket_launch':
        0xf055d, // action — accelerate, ascent, astronaut, boost, cosmic
    'rocket_launch_outlined':
        0xf0653, // [outline] action — accelerate, ascent, astronaut, boost, cosmic
    'rocket_launch_rounded':
        0xf0372, // [round] action — accelerate, ascent, astronaut, boost, cosmic
    'rocket_launch_sharp':
        0xf0465, // [sharp] action — accelerate, ascent, astronaut, boost, cosmic
    'rocket_outlined':
        0xf0654, // [outline] action — adventure, ascent, astronaut, astronomy, boost
    'rocket_rounded':
        0xf0373, // [round] action — adventure, ascent, astronaut, astronomy, boost
    'rocket_sharp':
        0xf0466, // [sharp] action — adventure, ascent, astronaut, astronomy, boost
    'roller_shades':
        0xf07bc, // home — adjust, automation, blinds, close, closed
    'roller_shades_closed':
        0xf07bd, // home — blinds, blinds closed, building control, closed, cover
    'roller_shades_closed_outlined':
        0xf070c, // [outline] home — blinds, blinds closed, building control, closed, cover
    'roller_shades_closed_rounded':
        0xf0814, // [round] home — blinds, blinds closed, building control, closed, cover
    'roller_shades_closed_sharp':
        0xf0764, // [sharp] home — blinds, blinds closed, building control, closed, cover
    'roller_shades_outlined':
        0xf070d, // [outline] home — adjust, automation, blinds, close, closed
    'roller_shades_rounded':
        0xf0815, // [round] home — adjust, automation, blinds, close, closed
    'roller_shades_sharp':
        0xf0765, // [sharp] home — adjust, automation, blinds, close, closed
    'roller_skating':
        0xf06c0, // social — active, activity, athlete, athletic, blade
    'roller_skating_outlined':
        0xf06a6, // [outline] social — active, activity, athlete, athletic, blade
    'roller_skating_rounded':
        0xf06cd, // [round] social — active, activity, athlete, athletic, blade
    'roller_skating_sharp':
        0xf06b3, // [sharp] social — active, activity, athlete, athletic, blade
    'roofing': 0xe53a, // places — angle, apex, architecture, builder, building
    'roofing_outlined':
        0xf31d, // [outline] places — angle, apex, architecture, builder, building
    'roofing_rounded':
        0xf010f, // [round] places — angle, apex, architecture, builder, building
    'roofing_sharp':
        0xec30, // [sharp] places — angle, apex, architecture, builder, building
    'room':
        0xe53b, // action — address, area, current location, destination, direction
    'room_outlined':
        0xf31e, // [outline] action — address, area, current location, destination, direction
    'room_preferences':
        0xe53c, // places — adjust, apartment, blueprint, building, configuration
    'room_preferences_outlined':
        0xf31f, // [outline] places — adjust, apartment, blueprint, building, configuration
    'room_preferences_rounded':
        0xf0110, // [round] places — adjust, apartment, blueprint, building, configuration
    'room_preferences_sharp':
        0xec31, // [sharp] places — adjust, apartment, blueprint, building, configuration
    'room_rounded':
        0xf0111, // [round] action — address, area, current location, destination, direction
    'room_service': 0xe53d, // places — alert, amenity, bell, breakfast, call
    'room_service_outlined':
        0xf320, // [outline] places — alert, amenity, bell, breakfast, call
    'room_service_rounded':
        0xf0112, // [round] places — alert, amenity, bell, breakfast, call
    'room_service_sharp':
        0xec32, // [sharp] places — alert, amenity, bell, breakfast, call
    'room_sharp':
        0xec33, // [sharp] action — address, area, current location, destination, direction
    'rotate_90_degrees_ccw':
        0xe53e, // image — 90, 90 degrees, adjustment, angle, arrow
    'rotate_90_degrees_ccw_outlined':
        0xf321, // [outline] image — 90, 90 degrees, adjustment, angle, arrow
    'rotate_90_degrees_ccw_rounded':
        0xf0113, // [round] image — 90, 90 degrees, adjustment, angle, arrow
    'rotate_90_degrees_ccw_sharp':
        0xec34, // [sharp] image — 90, 90 degrees, adjustment, angle, arrow
    'rotate_90_degrees_cw':
        0xf055e, // image — 90, 90 degree turn, 90 degrees, adjust, angle
    'rotate_90_degrees_cw_outlined':
        0xf0655, // [outline] image — 90, 90 degree turn, 90 degrees, adjust, angle
    'rotate_90_degrees_cw_rounded':
        0xf0374, // [round] image — 90, 90 degree turn, 90 degrees, adjust, angle
    'rotate_90_degrees_cw_sharp':
        0xf0467, // [sharp] image — 90, 90 degree turn, 90 degrees, adjust, angle
    'rotate_left': 0xe53f, // image — adjust, around, arrow, back, change
    'rotate_left_outlined':
        0xf322, // [outline] image — adjust, around, arrow, back, change
    'rotate_left_rounded':
        0xf0114, // [round] image — adjust, around, arrow, back, change
    'rotate_left_sharp':
        0xec35, // [sharp] image — adjust, around, arrow, back, change
    'rotate_right':
        0xe540, // image — around, arrow, change direction, circular, circular arrow
    'rotate_right_outlined':
        0xf323, // [outline] image — around, arrow, change direction, circular, circular arrow
    'rotate_right_rounded':
        0xf0115, // [round] image — around, arrow, change direction, circular, circular arrow
    'rotate_right_sharp':
        0xec36, // [sharp] image — around, arrow, change direction, circular, circular arrow
    'roundabout_left':
        0xf055f, // maps — arrow, arrows, circle, circular intersection, curved arrow
    'roundabout_left_outlined':
        0xf0656, // [outline] maps — arrow, arrows, circle, circular intersection, curved arrow
    'roundabout_left_rounded':
        0xf0375, // [round] maps — arrow, arrows, circle, circular intersection, curved arrow
    'roundabout_left_sharp':
        0xf0468, // [sharp] maps — arrow, arrows, circle, circular intersection, curved arrow
    'roundabout_right':
        0xf0560, // maps — arrow, arrows, circular intersection, crossroads, curved arrow
    'roundabout_right_outlined':
        0xf0657, // [outline] maps — arrow, arrows, circular intersection, crossroads, curved arrow
    'roundabout_right_rounded':
        0xf0376, // [round] maps — arrow, arrows, circular intersection, crossroads, curved arrow
    'roundabout_right_sharp':
        0xf0469, // [sharp] maps — arrow, arrows, circular intersection, crossroads, curved arrow
    'rounded_corner': 0xe541, // action — adjust, boundary, box, chamfer, corner
    'rounded_corner_outlined':
        0xf324, // [outline] action — adjust, boundary, box, chamfer, corner
    'rounded_corner_rounded':
        0xf0116, // [round] action — adjust, boundary, box, chamfer, corner
    'rounded_corner_sharp':
        0xec37, // [sharp] action — adjust, boundary, box, chamfer, corner
    'route':
        0xf0561, // maps — connection, connection line, course, destination, direction line
    'route_outlined':
        0xf0658, // [outline] maps — connection, connection line, course, destination, direction line
    'route_rounded':
        0xf0377, // [round] maps — connection, connection line, course, destination, direction line
    'route_sharp':
        0xf046a, // [sharp] maps — connection, connection line, course, destination, direction line
    'router':
        0xe542, // hardware — access point, box, broadband, cable, communication
    'router_outlined':
        0xf325, // [outline] hardware — access point, box, broadband, cable, communication
    'router_rounded':
        0xf0117, // [round] hardware — access point, box, broadband, cable, communication
    'router_sharp':
        0xec38, // [sharp] hardware — access point, box, broadband, cable, communication
    'rowing': 0xe543, // action — activity, athlete, boat, body, canoe
    'rowing_outlined':
        0xf326, // [outline] action — activity, athlete, boat, body, canoe
    'rowing_rounded':
        0xf0118, // [round] action — activity, athlete, boat, body, canoe
    'rowing_sharp':
        0xec39, // [sharp] action — activity, athlete, boat, body, canoe
    'rss_feed': 0xe544, // communication — antenna, arc, atom, blog, broadcast
    'rss_feed_outlined':
        0xf327, // [outline] communication — antenna, arc, atom, blog, broadcast
    'rss_feed_rounded':
        0xf0119, // [round] communication — antenna, arc, atom, blog, broadcast
    'rss_feed_sharp':
        0xec3a, // [sharp] communication — antenna, arc, atom, blog, broadcast
    'rsvp': 0xe545, // device — accept, accepted, acknowledged, affirmed, agree
    'rsvp_outlined':
        0xf328, // [outline] device — accept, accepted, acknowledged, affirmed, agree
    'rsvp_rounded':
        0xf011a, // [round] device — accept, accepted, acknowledged, affirmed, agree
    'rsvp_sharp':
        0xec3b, // [sharp] device — accept, accepted, acknowledged, affirmed, agree
    'rtt': 0xe546, // communication — accessibility, aid, assistance, call, chat
    'rtt_outlined':
        0xf329, // [outline] communication — accessibility, aid, assistance, call, chat
    'rtt_rounded':
        0xf011b, // [round] communication — accessibility, aid, assistance, call, chat
    'rtt_sharp':
        0xec3c, // [sharp] communication — accessibility, aid, assistance, call, chat
    'rule': 0xe547, // action — approve, automation, check, command, commands
    'rule_folder':
        0xe548, // file — administration, approve, archive, archive folder, business
    'rule_folder_outlined':
        0xf32a, // [outline] file — administration, approve, archive, archive folder, business
    'rule_folder_rounded':
        0xf011c, // [round] file — administration, approve, archive, archive folder, business
    'rule_folder_sharp':
        0xec3d, // [sharp] file — administration, approve, archive, archive folder, business
    'rule_outlined':
        0xf32b, // [outline] action — approve, automation, check, command, commands
    'rule_rounded':
        0xf011d, // [round] action — approve, automation, check, command, commands
    'rule_sharp':
        0xec3e, // [sharp] action — approve, automation, check, command, commands
    'run_circle': 0xe549, // maps — active, activity, athletics, begin, body
    'run_circle_outlined':
        0xf32c, // [outline] maps — active, activity, athletics, begin, body
    'run_circle_rounded':
        0xf011e, // [round] maps — active, activity, athletics, begin, body
    'run_circle_sharp':
        0xec3f, // [sharp] maps — active, activity, athletics, begin, body
    'running_with_errors':
        0xe54a, // notification — !, activity, alert, attention, blocked
    'running_with_errors_outlined':
        0xf32d, // [outline] notification — !, activity, alert, attention, blocked
    'running_with_errors_rounded':
        0xf011f, // [round] notification — !, activity, alert, attention, blocked
    'running_with_errors_sharp':
        0xec40, // [sharp] notification — !, activity, alert, attention, blocked
    'rv_hookup': 0xe54b, // places — arrow, attach, automobile, automotive, back
    'rv_hookup_outlined':
        0xf32e, // [outline] places — arrow, attach, automobile, automotive, back
    'rv_hookup_rounded':
        0xf0120, // [round] places — arrow, attach, automobile, automotive, back
    'rv_hookup_sharp':
        0xec41, // [sharp] places — arrow, attach, automobile, automotive, back
    'safety_check':
        0xf07be, // maps — approved, authentic, authentication, certified, check
    'safety_check_outlined':
        0xf070e, // [outline] maps — approved, authentic, authentication, certified, check
    'safety_check_rounded':
        0xf0816, // [round] maps — approved, authentic, authentication, certified, check
    'safety_check_sharp':
        0xf0766, // [sharp] maps — approved, authentic, authentication, certified, check
    'safety_divider':
        0xe54c, // social — apart, barrier, boundary, delineate, demarcation
    'safety_divider_outlined':
        0xf32f, // [outline] social — apart, barrier, boundary, delineate, demarcation
    'safety_divider_rounded':
        0xf0121, // [round] social — apart, barrier, boundary, delineate, demarcation
    'safety_divider_sharp':
        0xec42, // [sharp] social — apart, barrier, boundary, delineate, demarcation
    'sailing': 0xe54d, // maps — adventure, aquatic, boat, boating, cruise
    'sailing_outlined':
        0xf330, // [outline] maps — adventure, aquatic, boat, boating, cruise
    'sailing_rounded':
        0xf0122, // [round] maps — adventure, aquatic, boat, boating, cruise
    'sailing_sharp':
        0xec43, // [sharp] maps — adventure, aquatic, boat, boating, cruise
    'sanitizer':
        0xe54e, // social — anti-bacterial, bacteria, bathroom, bottle, clean
    'sanitizer_outlined':
        0xf331, // [outline] social — anti-bacterial, bacteria, bathroom, bottle, clean
    'sanitizer_rounded':
        0xf0123, // [round] social — anti-bacterial, bacteria, bathroom, bottle, clean
    'sanitizer_sharp':
        0xec44, // [sharp] social — anti-bacterial, bacteria, bathroom, bottle, clean
    'satellite':
        0xe54f, // maps — antenna, astronomy, bluetooth, broadcast, communication
    'satellite_alt':
        0xf0562, // action — alternative, antenna, artificial, astronomy, broadcast
    'satellite_alt_outlined':
        0xf0659, // [outline] action — alternative, antenna, artificial, astronomy, broadcast
    'satellite_alt_rounded':
        0xf0378, // [round] action — alternative, antenna, artificial, astronomy, broadcast
    'satellite_alt_sharp':
        0xf046b, // [sharp] action — alternative, antenna, artificial, astronomy, broadcast
    'satellite_outlined':
        0xf332, // [outline] maps — antenna, astronomy, bluetooth, broadcast, communication
    'satellite_rounded':
        0xf0124, // [round] maps — antenna, astronomy, bluetooth, broadcast, communication
    'satellite_sharp':
        0xec45, // [sharp] maps — antenna, astronomy, bluetooth, broadcast, communication
    'save': 0xe550, // content — backup, computer, disk, document, drive
    'save_alt': 0xe551, // content — acquire, alt, archive, arrow, bar
    'save_alt_outlined':
        0xf333, // [outline] content — acquire, alt, archive, arrow, bar
    'save_alt_rounded':
        0xf0125, // [round] content — acquire, alt, archive, arrow, bar
    'save_alt_sharp':
        0xec46, // [sharp] content — acquire, alt, archive, arrow, bar
    'save_as': 0xf0563, // content — archive, backup, classic, compose, computer
    'save_as_outlined':
        0xf065a, // [outline] content — archive, backup, classic, compose, computer
    'save_as_rounded':
        0xf0379, // [round] content — archive, backup, classic, compose, computer
    'save_as_sharp':
        0xf046c, // [sharp] content — archive, backup, classic, compose, computer
    'save_outlined':
        0xf334, // [outline] content — backup, computer, disk, document, drive
    'save_rounded':
        0xf0126, // [round] content — backup, computer, disk, document, drive
    'save_sharp':
        0xec47, // [sharp] content — backup, computer, disk, document, drive
    'saved_search':
        0xe552, // action — archive, bookmark, criteria, discover, explore
    'saved_search_outlined':
        0xf335, // [outline] action — archive, bookmark, criteria, discover, explore
    'saved_search_rounded':
        0xf0127, // [round] action — archive, bookmark, criteria, discover, explore
    'saved_search_sharp':
        0xec48, // [sharp] action — archive, bookmark, criteria, discover, explore
    'savings': 0xe553, // action — account, bank, banking, bill, budget
    'savings_outlined':
        0xf336, // [outline] action — account, bank, banking, bill, budget
    'savings_rounded':
        0xf0128, // [round] action — account, bank, banking, bill, budget
    'savings_sharp':
        0xec49, // [sharp] action — account, bank, banking, bill, budget
    'scale':
        0xf0564, // social — balance, balance scale, compare, compare measure, compare weight
    'scale_outlined':
        0xf065b, // [outline] social — balance, balance scale, compare, compare measure, compare weight
    'scale_rounded':
        0xf037a, // [round] social — balance, balance scale, compare, compare measure, compare weight
    'scale_sharp':
        0xf046d, // [sharp] social — balance, balance scale, compare, compare measure, compare weight
    'scanner': 0xe554, // hardware — authenticate, barcode, box, camera, code
    'scanner_outlined':
        0xf337, // [outline] hardware — authenticate, barcode, box, camera, code
    'scanner_rounded':
        0xf0129, // [round] hardware — authenticate, barcode, box, camera, code
    'scanner_sharp':
        0xec4a, // [sharp] hardware — authenticate, barcode, box, camera, code
    'scatter_plot': 0xe555, // editor — analysis, analytics, bar, bars, chart
    'scatter_plot_outlined':
        0xf338, // [outline] editor — analysis, analytics, bar, bars, chart
    'scatter_plot_rounded':
        0xf012a, // [round] editor — analysis, analytics, bar, bars, chart
    'scatter_plot_sharp':
        0xec4b, // [sharp] editor — analysis, analytics, bar, bars, chart
    'schedule':
        0xe556, // action — alarm, appointment, calendar, chronometer, clock
    'schedule_outlined':
        0xf339, // [outline] action — alarm, appointment, calendar, chronometer, clock
    'schedule_rounded':
        0xf012b, // [round] action — alarm, appointment, calendar, chronometer, clock
    'schedule_send':
        0xe557, // action — agenda, appointment, arrow, calendar, circle
    'schedule_send_outlined':
        0xf33a, // [outline] action — agenda, appointment, arrow, calendar, circle
    'schedule_send_rounded':
        0xf012c, // [round] action — agenda, appointment, arrow, calendar, circle
    'schedule_send_sharp':
        0xec4c, // [sharp] action — agenda, appointment, arrow, calendar, circle
    'schedule_sharp':
        0xec4d, // [sharp] action — alarm, appointment, calendar, chronometer, clock
    'schema':
        0xe558, // editor — analytics, architecture, blueprint, boxes, chart
    'schema_outlined':
        0xf33b, // [outline] editor — analytics, architecture, blueprint, boxes, chart
    'schema_rounded':
        0xf012d, // [round] editor — analytics, architecture, blueprint, boxes, chart
    'schema_sharp':
        0xec4e, // [sharp] editor — analytics, architecture, blueprint, boxes, chart
    'school':
        0xe559, // social — academic, academics, academy, achievement, architecture
    'school_outlined':
        0xf33c, // [outline] social — academic, academics, academy, achievement, architecture
    'school_rounded':
        0xf012e, // [round] social — academic, academics, academy, achievement, architecture
    'school_sharp':
        0xec4f, // [sharp] social — academic, academics, academy, achievement, architecture
    'science':
        0xe55a, // social — analysis, beaker, chemical, chemistry, container
    'science_outlined':
        0xf33d, // [outline] social — analysis, beaker, chemical, chemistry, container
    'science_rounded':
        0xf012f, // [round] social — analysis, beaker, chemical, chemistry, container
    'science_sharp':
        0xec50, // [sharp] social — analysis, beaker, chemical, chemistry, container
    'score': 0xe55b, // editor — 2k, achievement, alphabet, amount, analytics
    'score_outlined':
        0xf33e, // [outline] editor — 2k, achievement, alphabet, amount, analytics
    'score_rounded':
        0xf0130, // [round] editor — 2k, achievement, alphabet, amount, analytics
    'score_sharp':
        0xec51, // [sharp] editor — 2k, achievement, alphabet, amount, analytics
    'scoreboard':
        0xf06c1, // social — board, competition, display, game, information
    'scoreboard_outlined':
        0xf06a7, // [outline] social — board, competition, display, game, information
    'scoreboard_rounded':
        0xf06ce, // [round] social — board, competition, display, game, information
    'scoreboard_sharp':
        0xf06b4, // [sharp] social — board, competition, display, game, information
    'screen_lock_landscape':
        0xe55c, // device — Android, OS, access, device, device lock
    'screen_lock_landscape_outlined':
        0xf33f, // [outline] device — Android, OS, access, device, device lock
    'screen_lock_landscape_rounded':
        0xf0131, // [round] device — Android, OS, access, device, device lock
    'screen_lock_landscape_sharp':
        0xec52, // [sharp] device — Android, OS, access, device, device lock
    'screen_lock_portrait':
        0xe55d, // device — Android, OS, access, access control, authentication
    'screen_lock_portrait_outlined':
        0xf340, // [outline] device — Android, OS, access, access control, authentication
    'screen_lock_portrait_rounded':
        0xf0132, // [round] device — Android, OS, access, access control, authentication
    'screen_lock_portrait_sharp':
        0xec53, // [sharp] device — Android, OS, access, access control, authentication
    'screen_lock_rotation':
        0xe55e, // device — Android, OS, access, accessibility, arrow
    'screen_lock_rotation_outlined':
        0xf341, // [outline] device — Android, OS, access, accessibility, arrow
    'screen_lock_rotation_rounded':
        0xf0133, // [round] device — Android, OS, access, accessibility, arrow
    'screen_lock_rotation_sharp':
        0xec54, // [sharp] device — Android, OS, access, accessibility, arrow
    'screen_rotation': 0xe55f, // device — Android, OS, adjust, arrow, arrows
    'screen_rotation_alt':
        0xf07bf, // maps — Android, OS, adjust, alter, alternate
    'screen_rotation_alt_outlined':
        0xf070f, // [outline] maps — Android, OS, adjust, alter, alternate
    'screen_rotation_alt_rounded':
        0xf0817, // [round] maps — Android, OS, adjust, alter, alternate
    'screen_rotation_alt_sharp':
        0xf0767, // [sharp] maps — Android, OS, adjust, alter, alternate
    'screen_rotation_outlined':
        0xf342, // [outline] device — Android, OS, adjust, arrow, arrows
    'screen_rotation_rounded':
        0xf0134, // [round] device — Android, OS, adjust, arrow, arrows
    'screen_rotation_sharp':
        0xec55, // [sharp] device — Android, OS, adjust, arrow, arrows
    'screen_search_desktop':
        0xe560, // device — Android, OS, arrow, browser, computer
    'screen_search_desktop_outlined':
        0xf343, // [outline] device — Android, OS, arrow, browser, computer
    'screen_search_desktop_rounded':
        0xf0135, // [round] device — Android, OS, arrow, browser, computer
    'screen_search_desktop_sharp':
        0xec56, // [sharp] device — Android, OS, arrow, browser, computer
    'screen_share':
        0xe561, // communication — Android, OS, arrow, broadcast, cast
    'screen_share_outlined':
        0xf344, // [outline] communication — Android, OS, arrow, broadcast, cast
    'screen_share_rounded':
        0xf0136, // [round] communication — Android, OS, arrow, broadcast, cast
    'screen_share_sharp':
        0xec57, // [sharp] communication — Android, OS, arrow, broadcast, cast
    'screenshot': 0xe562, // device — Android, OS, art, camera, capture
    'screenshot_monitor':
        0xf07c0, // device — Android, OS, camera, capture, chrome
    'screenshot_monitor_outlined':
        0xf0710, // [outline] device — Android, OS, camera, capture, chrome
    'screenshot_monitor_rounded':
        0xf0818, // [round] device — Android, OS, camera, capture, chrome
    'screenshot_monitor_sharp':
        0xf0768, // [sharp] device — Android, OS, camera, capture, chrome
    'screenshot_outlined':
        0xf345, // [outline] device — Android, OS, art, camera, capture
    'screenshot_rounded':
        0xf0137, // [round] device — Android, OS, art, camera, capture
    'screenshot_sharp':
        0xec58, // [sharp] device — Android, OS, art, camera, capture
    'scuba_diving':
        0xf06c2, // social — activity, adventure, aquatic, deep sea, discovery
    'scuba_diving_outlined':
        0xf06a8, // [outline] social — activity, adventure, aquatic, deep sea, discovery
    'scuba_diving_rounded':
        0xf06cf, // [round] social — activity, adventure, aquatic, deep sea, discovery
    'scuba_diving_sharp':
        0xf06b5, // [sharp] social — activity, adventure, aquatic, deep sea, discovery
    'sd': 0xe563, // av — access, alphabet, authorized, camera, card
    'sd_card':
        0xe564, // notification — angled corner, camera, card, computer, data storage
    'sd_card_alert': 0xe565, // notification — !, alert, attention, camera, card
    'sd_card_alert_outlined':
        0xf346, // [outline] notification — !, alert, attention, camera, card
    'sd_card_alert_rounded':
        0xf0138, // [round] notification — !, alert, attention, camera, card
    'sd_card_alert_sharp':
        0xec59, // [sharp] notification — !, alert, attention, camera, card
    'sd_card_outlined':
        0xf347, // [outline] notification — angled corner, camera, card, computer, data storage
    'sd_card_rounded':
        0xf0139, // [round] notification — angled corner, camera, card, computer, data storage
    'sd_card_sharp':
        0xec5a, // [sharp] notification — angled corner, camera, card, computer, data storage
    'sd_outlined':
        0xf348, // [outline] av — access, alphabet, authorized, camera, card
    'sd_rounded':
        0xf013a, // [round] av — access, alphabet, authorized, camera, card
    'sd_sharp':
        0xec5b, // [sharp] av — access, alphabet, authorized, camera, card
    'sd_storage':
        0xe566, // device — angled corner, camera, card, computer, data storage
    'sd_storage_outlined':
        0xf349, // [outline] device — angled corner, camera, card, computer, data storage
    'sd_storage_rounded':
        0xf013b, // [round] device — angled corner, camera, card, computer, data storage
    'sd_storage_sharp':
        0xec5c, // [sharp] device — angled corner, camera, card, computer, data storage
    'search': 0xe567, // action — browse, circle, discover, explore, filter
    'search_off':
        0xe568, // action — access denied, blocked, blocked access, cancel, cancel search
    'search_off_outlined':
        0xf34a, // [outline] action — access denied, blocked, blocked access, cancel, cancel search
    'search_off_rounded':
        0xf013c, // [round] action — access denied, blocked, blocked access, cancel, cancel search
    'search_off_sharp':
        0xec5d, // [sharp] action — access denied, blocked, blocked access, cancel, cancel search
    'search_outlined':
        0xf34b, // [outline] action — browse, circle, discover, explore, filter
    'search_rounded':
        0xf013d, // [round] action — browse, circle, discover, explore, filter
    'search_sharp':
        0xec5e, // [sharp] action — browse, circle, discover, explore, filter
    'security':
        0xe569, // hardware — access, allowed, authentication, certified, data security
    'security_outlined':
        0xf34c, // [outline] hardware — access, allowed, authentication, certified, data security
    'security_rounded':
        0xf013e, // [round] hardware — access, allowed, authentication, certified, data security
    'security_sharp':
        0xec5f, // [sharp] hardware — access, allowed, authentication, certified, data security
    'security_update':
        0xe56a, // device — Android, OS, app install, app promo, arrow
    'security_update_good':
        0xe56b, // device — Android, OS, approve, approved, cell
    'security_update_good_outlined':
        0xf34d, // [outline] device — Android, OS, approve, approved, cell
    'security_update_good_rounded':
        0xf013f, // [round] device — Android, OS, approve, approved, cell
    'security_update_good_sharp':
        0xec60, // [sharp] device — Android, OS, approve, approved, cell
    'security_update_outlined':
        0xf34e, // [outline] device — Android, OS, app install, app promo, arrow
    'security_update_rounded':
        0xf0140, // [round] device — Android, OS, app install, app promo, arrow
    'security_update_sharp':
        0xec61, // [sharp] device — Android, OS, app install, app promo, arrow
    'security_update_warning':
        0xe56c, // device — !, Android, OS, alert, attention
    'security_update_warning_outlined':
        0xf34f, // [outline] device — !, Android, OS, alert, attention
    'security_update_warning_rounded':
        0xf0141, // [round] device — !, Android, OS, alert, attention
    'security_update_warning_sharp':
        0xec62, // [sharp] device — !, Android, OS, alert, attention
    'segment':
        0xe56d, // action — alignment, analytics, analyze, breakdown, categorize
    'segment_outlined':
        0xf350, // [outline] action — alignment, analytics, analyze, breakdown, categorize
    'segment_rounded':
        0xf0142, // [round] action — alignment, analytics, analyze, breakdown, categorize
    'segment_sharp':
        0xec63, // [sharp] action — alignment, analytics, analyze, breakdown, categorize
    'select_all': 0xe56e, // content — all, batch, box, bulk, check
    'select_all_outlined':
        0xf351, // [outline] content — all, batch, box, bulk, check
    'select_all_rounded':
        0xf0143, // [round] content — all, batch, box, bulk, check
    'select_all_sharp':
        0xec64, // [sharp] content — all, batch, box, bulk, check
    'self_improvement': 0xe56f, // social — balance, body, brain, calm, care
    'self_improvement_outlined':
        0xf352, // [outline] social — balance, body, brain, calm, care
    'self_improvement_rounded':
        0xf0144, // [round] social — balance, body, brain, calm, care
    'self_improvement_sharp':
        0xec65, // [sharp] social — balance, body, brain, calm, care
    'sell': 0xe570, // device — bargain, bill, card, cart, cash
    'sell_outlined':
        0xf353, // [outline] device — bargain, bill, card, cart, cash
    'sell_rounded': 0xf0145, // [round] device — bargain, bill, card, cart, cash
    'sell_sharp': 0xec66, // [sharp] device — bargain, bill, card, cart, cash
    'send': 0xe571, // content — airplane, arrow, chat, communication, complete
    'send_and_archive':
        0xe572, // action — archive, arrow, box, chat, chat message
    'send_and_archive_outlined':
        0xf354, // [outline] action — archive, arrow, box, chat, chat message
    'send_and_archive_rounded':
        0xf0146, // [round] action — archive, arrow, box, chat, chat message
    'send_and_archive_sharp':
        0xec67, // [sharp] action — archive, arrow, box, chat, chat message
    'send_outlined':
        0xf355, // [outline] content — airplane, arrow, chat, communication, complete
    'send_rounded':
        0xf0147, // [round] content — airplane, arrow, chat, communication, complete
    'send_sharp':
        0xec68, // [sharp] content — airplane, arrow, chat, communication, complete
    'send_time_extension':
        0xf0565, // communication — add, add time, arrow, clock, communication
    'send_time_extension_outlined':
        0xf065c, // [outline] communication — add, add time, arrow, clock, communication
    'send_time_extension_rounded':
        0xf037b, // [round] communication — add, add time, arrow, clock, communication
    'send_time_extension_sharp':
        0xf046e, // [sharp] communication — add, add time, arrow, clock, communication
    'send_to_mobile': 0xe573, // device — Android, OS, abstract, arrow, cellular
    'send_to_mobile_outlined':
        0xf356, // [outline] device — Android, OS, abstract, arrow, cellular
    'send_to_mobile_rounded':
        0xf0148, // [round] device — Android, OS, abstract, arrow, cellular
    'send_to_mobile_sharp':
        0xec69, // [sharp] device — Android, OS, abstract, arrow, cellular
    'sensor_door':
        0xe574, // home — access, access point, alarm, alert, automation
    'sensor_door_outlined':
        0xf357, // [outline] home — access, access point, alarm, alert, automation
    'sensor_door_rounded':
        0xf0149, // [round] home — access, access point, alarm, alert, automation
    'sensor_door_sharp':
        0xec6a, // [sharp] home — access, access point, alarm, alert, automation
    'sensor_occupied':
        0xf07c1, // home — activated, active, alarm, alert, automation
    'sensor_occupied_outlined':
        0xf0711, // [outline] home — activated, active, alarm, alert, automation
    'sensor_occupied_rounded':
        0xf0819, // [round] home — activated, active, alarm, alert, automation
    'sensor_occupied_sharp':
        0xf0769, // [sharp] home — activated, active, alarm, alert, automation
    'sensor_window': 0xe575, // home — alarm, area, boundary, camera, detection
    'sensor_window_outlined':
        0xf358, // [outline] home — alarm, area, boundary, camera, detection
    'sensor_window_rounded':
        0xf014a, // [round] home — alarm, area, boundary, camera, detection
    'sensor_window_sharp':
        0xec6b, // [sharp] home — alarm, area, boundary, camera, detection
    'sensors':
        0xe576, // action — antenna, bar graph, bars, communication, connection
    'sensors_off':
        0xe577, // action — block, cancel, connection, crossed out, detection off
    'sensors_off_outlined':
        0xf359, // [outline] action — block, cancel, connection, crossed out, detection off
    'sensors_off_rounded':
        0xf014b, // [round] action — block, cancel, connection, crossed out, detection off
    'sensors_off_sharp':
        0xec6c, // [sharp] action — block, cancel, connection, crossed out, detection off
    'sensors_outlined':
        0xf35a, // [outline] action — antenna, bar graph, bars, communication, connection
    'sensors_rounded':
        0xf014c, // [round] action — antenna, bar graph, bars, communication, connection
    'sensors_sharp':
        0xec6d, // [sharp] action — antenna, bar graph, bars, communication, connection
    'sentiment_dissatisfied':
        0xe578, // social — angry, avatar, bad, circle, disappointed
    'sentiment_dissatisfied_outlined':
        0xf35b, // [outline] social — angry, avatar, bad, circle, disappointed
    'sentiment_dissatisfied_rounded':
        0xf014d, // [round] social — angry, avatar, bad, circle, disappointed
    'sentiment_dissatisfied_sharp':
        0xec6e, // [sharp] social — angry, avatar, bad, circle, disappointed
    'sentiment_neutral':
        0xe579, // social — attitude, avatar, average, emoji, emotion
    'sentiment_neutral_outlined':
        0xf35c, // [outline] social — attitude, avatar, average, emoji, emotion
    'sentiment_neutral_rounded':
        0xf014e, // [round] social — attitude, avatar, average, emoji, emotion
    'sentiment_neutral_sharp':
        0xec6f, // [sharp] social — attitude, avatar, average, emoji, emotion
    'sentiment_satisfied':
        0xe57a, // social — cheerful, circle, emoji, emoticon, emotion
    'sentiment_satisfied_alt':
        0xe57b, // communication — account, alt, cheerful, circle, emoji
    'sentiment_satisfied_alt_outlined':
        0xf35d, // [outline] communication — account, alt, cheerful, circle, emoji
    'sentiment_satisfied_alt_rounded':
        0xf014f, // [round] communication — account, alt, cheerful, circle, emoji
    'sentiment_satisfied_alt_sharp':
        0xec70, // [sharp] communication — account, alt, cheerful, circle, emoji
    'sentiment_satisfied_outlined':
        0xf35e, // [outline] social — cheerful, circle, emoji, emoticon, emotion
    'sentiment_satisfied_rounded':
        0xf0150, // [round] social — cheerful, circle, emoji, emoticon, emotion
    'sentiment_satisfied_sharp':
        0xec71, // [sharp] social — cheerful, circle, emoji, emoticon, emotion
    'sentiment_very_dissatisfied':
        0xe57c, // social — angry, avatar, character, circle, disappointed
    'sentiment_very_dissatisfied_outlined':
        0xf35f, // [outline] social — angry, avatar, character, circle, disappointed
    'sentiment_very_dissatisfied_rounded':
        0xf0151, // [round] social — angry, avatar, character, circle, disappointed
    'sentiment_very_dissatisfied_sharp':
        0xec72, // [sharp] social — angry, avatar, character, circle, disappointed
    'sentiment_very_satisfied':
        0xe57d, // social — approval, avatar, character, cheerful, circle
    'sentiment_very_satisfied_outlined':
        0xf360, // [outline] social — approval, avatar, character, cheerful, circle
    'sentiment_very_satisfied_rounded':
        0xf0152, // [round] social — approval, avatar, character, cheerful, circle
    'sentiment_very_satisfied_sharp':
        0xec73, // [sharp] social — approval, avatar, character, cheerful, circle
    'set_meal':
        0xe57e, // maps — chopsticks, cutlery, dining, dining etiquette, dining room
    'set_meal_outlined':
        0xf361, // [outline] maps — chopsticks, cutlery, dining, dining etiquette, dining room
    'set_meal_rounded':
        0xf0153, // [round] maps — chopsticks, cutlery, dining, dining etiquette, dining room
    'set_meal_sharp':
        0xec74, // [sharp] maps — chopsticks, cutlery, dining, dining etiquette, dining room
    'settings':
        0xe57f, // action — adjustments, administration, administration panel, change, cog
    'settings_accessibility':
        0xe580, // action — access, accessibility, adaptation, adjustments, aids
    'settings_accessibility_outlined':
        0xf362, // [outline] action — access, accessibility, adaptation, adjustments, aids
    'settings_accessibility_rounded':
        0xf0154, // [round] action — access, accessibility, adaptation, adjustments, aids
    'settings_accessibility_sharp':
        0xec75, // [sharp] action — access, accessibility, adaptation, adjustments, aids
    'settings_applications':
        0xe581, // action — adjust, administration, applications, change, circle
    'settings_applications_outlined':
        0xf363, // [outline] action — adjust, administration, applications, change, circle
    'settings_applications_rounded':
        0xf0155, // [round] action — adjust, administration, applications, change, circle
    'settings_applications_sharp':
        0xec76, // [sharp] action — adjust, administration, applications, change, circle
    'settings_backup_restore':
        0xe582, // action — archive, arrow, back, backup, backwards
    'settings_backup_restore_outlined':
        0xf364, // [outline] action — archive, arrow, back, backup, backwards
    'settings_backup_restore_rounded':
        0xf0156, // [round] action — archive, arrow, back, backup, backwards
    'settings_backup_restore_sharp':
        0xec77, // [sharp] action — archive, arrow, back, backup, backwards
    'settings_bluetooth':
        0xe583, // action — accessories, adjustments, audio, bluetooth, configuration
    'settings_bluetooth_outlined':
        0xf365, // [outline] action — accessories, adjustments, audio, bluetooth, configuration
    'settings_bluetooth_rounded':
        0xf0157, // [round] action — accessories, adjustments, audio, bluetooth, configuration
    'settings_bluetooth_sharp':
        0xec78, // [sharp] action — accessories, adjustments, audio, bluetooth, configuration
    'settings_brightness':
        0xe584, // action — adjust, adjustment, appearance, brightness, configuration
    'settings_brightness_outlined':
        0xf366, // [outline] action — adjust, adjustment, appearance, brightness, configuration
    'settings_brightness_rounded':
        0xf0158, // [round] action — adjust, adjustment, appearance, brightness, configuration
    'settings_brightness_sharp':
        0xec79, // [sharp] action — adjust, adjustment, appearance, brightness, configuration
    'settings_cell':
        0xe585, // action — Android, OS, adjustment, administration, administration panel
    'settings_cell_outlined':
        0xf367, // [outline] action — Android, OS, adjustment, administration, administration panel
    'settings_cell_rounded':
        0xf0159, // [round] action — Android, OS, adjustment, administration, administration panel
    'settings_cell_sharp':
        0xec7a, // [sharp] action — Android, OS, adjustment, administration, administration panel
    'settings_display':
        0xe584, // action — Android, OS, adjustments, brightness, change
    'settings_display_outlined':
        0xf366, // [outline] action — Android, OS, adjustments, brightness, change
    'settings_display_rounded':
        0xf0158, // [round] action — Android, OS, adjustments, brightness, change
    'settings_display_sharp':
        0xec79, // [sharp] action — Android, OS, adjustments, brightness, change
    'settings_ethernet':
        0xe586, // action — arrows, cable, communication, computer, computer network
    'settings_ethernet_outlined':
        0xf368, // [outline] action — arrows, cable, communication, computer, computer network
    'settings_ethernet_rounded':
        0xf015a, // [round] action — arrows, cable, communication, computer, computer network
    'settings_ethernet_sharp':
        0xec7b, // [sharp] action — arrows, cable, communication, computer, computer network
    'settings_input_antenna':
        0xe587, // action — airplay, antenna, arrows, broadcast, cast
    'settings_input_antenna_outlined':
        0xf369, // [outline] action — airplay, antenna, arrows, broadcast, cast
    'settings_input_antenna_rounded':
        0xf015b, // [round] action — airplay, antenna, arrows, broadcast, cast
    'settings_input_antenna_sharp':
        0xec7c, // [sharp] action — airplay, antenna, arrows, broadcast, cast
    'settings_input_component':
        0xe588, // action — audio, av, cable, cables, composite
    'settings_input_component_outlined':
        0xf36a, // [outline] action — audio, av, cable, cables, composite
    'settings_input_component_rounded':
        0xf015c, // [round] action — audio, av, cable, cables, composite
    'settings_input_component_sharp':
        0xec7d, // [sharp] action — audio, av, cable, cables, composite
    'settings_input_composite':
        0xe589, // action — audio, av, cables, composite, configure
    'settings_input_composite_outlined':
        0xf36b, // [outline] action — audio, av, cables, composite, configure
    'settings_input_composite_rounded':
        0xf015d, // [round] action — audio, av, cables, composite, configure
    'settings_input_composite_sharp':
        0xec7e, // [sharp] action — audio, av, cables, composite, configure
    'settings_input_hdmi':
        0xe58a, // action — audio, av, cable, configuration, connection
    'settings_input_hdmi_outlined':
        0xf36c, // [outline] action — audio, av, cable, configuration, connection
    'settings_input_hdmi_rounded':
        0xf015e, // [round] action — audio, av, cable, configuration, connection
    'settings_input_hdmi_sharp':
        0xec7f, // [sharp] action — audio, av, cable, configuration, connection
    'settings_input_svideo':
        0xe58b, // action — adapter, audio video, audio visual, av, cable
    'settings_input_svideo_outlined':
        0xf36d, // [outline] action — adapter, audio video, audio visual, av, cable
    'settings_input_svideo_rounded':
        0xf015f, // [round] action — adapter, audio video, audio visual, av, cable
    'settings_input_svideo_sharp':
        0xec80, // [sharp] action — adapter, audio video, audio visual, av, cable
    'settings_outlined':
        0xf36e, // [outline] action — adjustments, administration, administration panel, change, cog
    'settings_overscan':
        0xe58c, // action — adjustment, arrows, aspect ratio, box, calibration
    'settings_overscan_outlined':
        0xf36f, // [outline] action — adjustment, arrows, aspect ratio, box, calibration
    'settings_overscan_rounded':
        0xf0160, // [round] action — adjustment, arrows, aspect ratio, box, calibration
    'settings_overscan_sharp':
        0xec81, // [sharp] action — adjustment, arrows, aspect ratio, box, calibration
    'settings_phone':
        0xe58d, // action — adjust, administration, call, cell, cellular
    'settings_phone_outlined':
        0xf370, // [outline] action — adjust, administration, call, cell, cellular
    'settings_phone_rounded':
        0xf0161, // [round] action — adjust, administration, call, cell, cellular
    'settings_phone_sharp':
        0xec82, // [sharp] action — adjust, administration, call, cell, cellular
    'settings_power':
        0xe58e, // action — access, circle, device, electrical, electricity
    'settings_power_outlined':
        0xf371, // [outline] action — access, circle, device, electrical, electricity
    'settings_power_rounded':
        0xf0162, // [round] action — access, circle, device, electrical, electricity
    'settings_power_sharp':
        0xec83, // [sharp] action — access, circle, device, electrical, electricity
    'settings_remote':
        0xe58f, // action — access, access settings, adjustment, appliance, bluetooth
    'settings_remote_outlined':
        0xf372, // [outline] action — access, access settings, adjustment, appliance, bluetooth
    'settings_remote_rounded':
        0xf0163, // [round] action — access, access settings, adjustment, appliance, bluetooth
    'settings_remote_sharp':
        0xec84, // [sharp] action — access, access settings, adjustment, appliance, bluetooth
    'settings_rounded':
        0xf0164, // [round] action — adjustments, administration, administration panel, change, cog
    'settings_sharp':
        0xec85, // [sharp] action — adjustments, administration, administration panel, change, cog
    'settings_suggest':
        0xe590, // device — adjust, administration, advise, ai, artificial
    'settings_suggest_outlined':
        0xf373, // [outline] device — adjust, administration, advise, ai, artificial
    'settings_suggest_rounded':
        0xf0165, // [round] device — adjust, administration, advise, ai, artificial
    'settings_suggest_sharp':
        0xec86, // [sharp] device — adjust, administration, advise, ai, artificial
    'settings_system_daydream':
        0xe591, // device — adjustment, backup, cloud, configuration, daydream
    'settings_system_daydream_outlined':
        0xf374, // [outline] device — adjustment, backup, cloud, configuration, daydream
    'settings_system_daydream_rounded':
        0xf0166, // [round] device — adjustment, backup, cloud, configuration, daydream
    'settings_system_daydream_sharp':
        0xec87, // [sharp] device — adjustment, backup, cloud, configuration, daydream
    'settings_voice':
        0xe592, // action — adjustments, audio, circle, circular, cog
    'settings_voice_outlined':
        0xf375, // [outline] action — adjustments, audio, circle, circular, cog
    'settings_voice_rounded':
        0xf0167, // [round] action — adjustments, audio, circle, circular, cog
    'settings_voice_sharp':
        0xec88, // [sharp] action — adjustments, audio, circle, circular, cog
    'seven_k': 0xe02e, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_outlined':
        0xee20, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_plus': 0xe02f, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_plus_outlined':
        0xee21, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_plus_rounded':
        0xf50d, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_plus_sharp':
        0xe72e, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_rounded':
        0xf50e, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_k_sharp':
        0xe72f, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_mp': 0xe030, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_mp_outlined':
        0xee22, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_mp_rounded':
        0xf50f, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seven_mp_sharp':
        0xe730, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seventeen_mp': 0xe008, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'seventeen_mp_outlined':
        0xedfa, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seventeen_mp_rounded':
        0xf4e7, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'seventeen_mp_sharp':
        0xe708, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'severe_cold':
        0xf07c2, // social — !, alert, atmosphere, attention, blizzard
    'severe_cold_outlined':
        0xf0712, // [outline] social — !, alert, atmosphere, attention, blizzard
    'severe_cold_rounded':
        0xf081a, // [round] social — !, alert, atmosphere, attention, blizzard
    'severe_cold_sharp':
        0xf076a, // [sharp] social — !, alert, atmosphere, attention, blizzard
    'shape_line':
        0xf0876, // editor — circle, collapse, dash, decrease, delimiter
    'shape_line_outlined':
        0xf08b3, // [outline] editor — circle, collapse, dash, decrease, delimiter
    'shape_line_rounded':
        0xf0895, // [round] editor — circle, collapse, dash, decrease, delimiter
    'shape_line_sharp':
        0xf084c, // [sharp] editor — circle, collapse, dash, decrease, delimiter
    'share':
        0xe593, // social — activity, andriod share, android, arrow, communication
    'share_arrival_time': 0xe594,
    'share_arrival_time_outlined': 0xf376,
    'share_arrival_time_rounded': 0xf0168,
    'share_arrival_time_sharp': 0xec89,
    'share_location':
        0xe595, // device — address, area, broadcast, communicate, connect
    'share_location_outlined':
        0xf377, // [outline] device — address, area, broadcast, communicate, connect
    'share_location_rounded':
        0xf0169, // [round] device — address, area, broadcast, communicate, connect
    'share_location_sharp':
        0xec8a, // [sharp] device — address, area, broadcast, communicate, connect
    'share_outlined':
        0xf378, // [outline] social — activity, andriod share, android, arrow, communication
    'share_rounded':
        0xf016a, // [round] social — activity, andriod share, android, arrow, communication
    'share_sharp':
        0xec8b, // [sharp] social — activity, andriod share, android, arrow, communication
    'shelves': 0xf0877, // home — arrangement, books, box, business, catalogue
    'shield':
        0xe596, // content — access, authorized, certified, confidential, cyber security
    'shield_moon':
        0xf0566, // home — certified, confidential, crescent, crescent moon, dark mode
    'shield_moon_outlined':
        0xf065d, // [outline] home — certified, confidential, crescent, crescent moon, dark mode
    'shield_moon_rounded':
        0xf037c, // [round] home — certified, confidential, crescent, crescent moon, dark mode
    'shield_moon_sharp':
        0xf046f, // [sharp] home — certified, confidential, crescent, crescent moon, dark mode
    'shield_outlined':
        0xf379, // [outline] content — access, authorized, certified, confidential, cyber security
    'shield_rounded':
        0xf016b, // [round] content — access, authorized, certified, confidential, cyber security
    'shield_sharp':
        0xec8c, // [sharp] content — access, authorized, certified, confidential, cyber security
    'shop': 0xe597, // action — architecture, bag, bill, building, business
    'shop_2': 0xe598, // action — 2, add, arrow, basket, business
    'shop_2_outlined':
        0xf37a, // [outline] action — 2, add, arrow, basket, business
    'shop_2_rounded':
        0xf016c, // [round] action — 2, add, arrow, basket, business
    'shop_2_sharp': 0xec8d, // [sharp] action — 2, add, arrow, basket, business
    'shop_outlined':
        0xf37b, // [outline] action — architecture, bag, bill, building, business
    'shop_rounded':
        0xf016d, // [round] action — architecture, bag, bill, building, business
    'shop_sharp':
        0xec8e, // [sharp] action — architecture, bag, bill, building, business
    'shop_two': 0xe599, // action — 2, add, arrow, basket, business
    'shop_two_outlined':
        0xf37c, // [outline] action — 2, add, arrow, basket, business
    'shop_two_rounded':
        0xf016e, // [round] action — 2, add, arrow, basket, business
    'shop_two_sharp':
        0xec8f, // [sharp] action — 2, add, arrow, basket, business
    'shopify': 0xf0567,
    'shopify_outlined': 0xf065e,
    'shopify_rounded': 0xf037d,
    'shopify_sharp': 0xf0470,
    'shopping_bag': 0xe59a, // action — acquire, bag, basket, bill, business
    'shopping_bag_outlined':
        0xf37d, // [outline] action — acquire, bag, basket, bill, business
    'shopping_bag_rounded':
        0xf016f, // [round] action — acquire, bag, basket, bill, business
    'shopping_bag_sharp':
        0xec90, // [sharp] action — acquire, bag, basket, bill, business
    'shopping_basket': 0xe59b, // action — add, add to cart, bag, basket, bill
    'shopping_basket_outlined':
        0xf37e, // [outline] action — add, add to cart, bag, basket, bill
    'shopping_basket_rounded':
        0xf0170, // [round] action — add, add to cart, bag, basket, bill
    'shopping_basket_sharp':
        0xec91, // [sharp] action — add, add to cart, bag, basket, bill
    'shopping_cart': 0xe59c, // action — add, add to cart, basket, bill, buy
    'shopping_cart_checkout':
        0xf0568, // action — add, add to cart, arrow, bag, basket
    'shopping_cart_checkout_outlined':
        0xf065f, // [outline] action — add, add to cart, arrow, bag, basket
    'shopping_cart_checkout_rounded':
        0xf037e, // [round] action — add, add to cart, arrow, bag, basket
    'shopping_cart_checkout_sharp':
        0xf0471, // [sharp] action — add, add to cart, arrow, bag, basket
    'shopping_cart_outlined':
        0xf37f, // [outline] action — add, add to cart, basket, bill, buy
    'shopping_cart_rounded':
        0xf0171, // [round] action — add, add to cart, basket, bill, buy
    'shopping_cart_sharp':
        0xec92, // [sharp] action — add, add to cart, basket, bill, buy
    'short_text':
        0xe59d, // editor — abstract, article, block of text, brief, characters
    'short_text_outlined':
        0xf380, // [outline] editor — abstract, article, block of text, brief, characters
    'short_text_rounded':
        0xf0172, // [round] editor — abstract, article, block of text, brief, characters
    'short_text_sharp':
        0xec93, // [sharp] editor — abstract, article, block of text, brief, characters
    'shortcut':
        0xe59e, // device — arrow, communication, content sharing, direction, forward
    'shortcut_outlined':
        0xf381, // [outline] device — arrow, communication, content sharing, direction, forward
    'shortcut_rounded':
        0xf0173, // [round] device — arrow, communication, content sharing, direction, forward
    'shortcut_sharp':
        0xec94, // [sharp] device — arrow, communication, content sharing, direction, forward
    'show_chart': 0xe59f, // editor — analysis, analytics, bar, bars, business
    'show_chart_outlined':
        0xf382, // [outline] editor — analysis, analytics, bar, bars, business
    'show_chart_rounded':
        0xf0174, // [round] editor — analysis, analytics, bar, bars, business
    'show_chart_sharp':
        0xec95, // [sharp] editor — analysis, analytics, bar, bars, business
    'shower':
        0xe5a0, // search — apartment, bath, bathroom, cleaning, cleanliness
    'shower_outlined':
        0xf383, // [outline] search — apartment, bath, bathroom, cleaning, cleanliness
    'shower_rounded':
        0xf0175, // [round] search — apartment, bath, bathroom, cleaning, cleanliness
    'shower_sharp':
        0xec96, // [sharp] search — apartment, bath, bathroom, cleaning, cleanliness
    'shuffle': 0xe5a1, // av — alter order, arrange, arrow, arrows, change order
    'shuffle_on': 0xe5a2, // av — activate, active, arrow, arrows, audio
    'shuffle_on_outlined':
        0xf384, // [outline] av — activate, active, arrow, arrows, audio
    'shuffle_on_rounded':
        0xf0176, // [round] av — activate, active, arrow, arrows, audio
    'shuffle_on_sharp':
        0xec97, // [sharp] av — activate, active, arrow, arrows, audio
    'shuffle_outlined':
        0xf385, // [outline] av — alter order, arrange, arrow, arrows, change order
    'shuffle_rounded':
        0xf0177, // [round] av — alter order, arrange, arrow, arrows, change order
    'shuffle_sharp':
        0xec98, // [sharp] av — alter order, arrange, arrow, arrows, change order
    'shutter_speed':
        0xe5a3, // image — adjustment, aperture, aperture control, blades, camera
    'shutter_speed_outlined':
        0xf386, // [outline] image — adjustment, aperture, aperture control, blades, camera
    'shutter_speed_rounded':
        0xf0178, // [round] image — adjustment, aperture, aperture control, blades, camera
    'shutter_speed_sharp':
        0xec99, // [sharp] image — adjustment, aperture, aperture control, blades, camera
    'sick': 0xe5a4, // social — ailment, covid, discomfort, emoji, emoticon
    'sick_outlined':
        0xf387, // [outline] social — ailment, covid, discomfort, emoji, emoticon
    'sick_rounded':
        0xf0179, // [round] social — ailment, covid, discomfort, emoji, emoticon
    'sick_sharp':
        0xec9a, // [sharp] social — ailment, covid, discomfort, emoji, emoticon
    'sign_language':
        0xf07c3, // social — accessibility, audio, caption, communication, deaf
    'sign_language_outlined':
        0xf0713, // [outline] social — accessibility, audio, caption, communication, deaf
    'sign_language_rounded':
        0xf081b, // [round] social — accessibility, audio, caption, communication, deaf
    'sign_language_sharp':
        0xf076b, // [sharp] social — accessibility, audio, caption, communication, deaf
    'signal_cellular_0_bar':
        0xe5a5, // device — 0, 0 bars, antenna, bad signal, bar
    'signal_cellular_0_bar_outlined':
        0xf388, // [outline] device — 0, 0 bars, antenna, bad signal, bar
    'signal_cellular_0_bar_rounded':
        0xf017a, // [round] device — 0, 0 bars, antenna, bad signal, bar
    'signal_cellular_0_bar_sharp':
        0xec9b, // [sharp] device — 0, 0 bars, antenna, bad signal, bar
    'signal_cellular_4_bar':
        0xe5a6, // device — 0, bar, bars, bars increasing, cell
    'signal_cellular_4_bar_outlined':
        0xf389, // [outline] device — 0, bar, bars, bars increasing, cell
    'signal_cellular_4_bar_rounded':
        0xf017b, // [round] device — 0, bar, bars, bars increasing, cell
    'signal_cellular_4_bar_sharp':
        0xec9c, // [sharp] device — 0, bar, bars, bars increasing, cell
    'signal_cellular_alt':
        0xe5a7, // device — alt, analytics, ascending bars, bar, bars
    'signal_cellular_alt_1_bar':
        0xf07c4, // device — 1 bar, alt, analytics, antenna, bar
    'signal_cellular_alt_1_bar_outlined':
        0xf0714, // [outline] device — 1 bar, alt, analytics, antenna, bar
    'signal_cellular_alt_1_bar_rounded':
        0xf081c, // [round] device — 1 bar, alt, analytics, antenna, bar
    'signal_cellular_alt_1_bar_sharp':
        0xf076c, // [sharp] device — 1 bar, alt, analytics, antenna, bar
    'signal_cellular_alt_2_bar':
        0xf07c5, // device — alt, analytics, bar, bars, bars up
    'signal_cellular_alt_2_bar_outlined':
        0xf0715, // [outline] device — alt, analytics, bar, bars, bars up
    'signal_cellular_alt_2_bar_rounded':
        0xf081d, // [round] device — alt, analytics, bar, bars, bars up
    'signal_cellular_alt_2_bar_sharp':
        0xf076d, // [sharp] device — alt, analytics, bar, bars, bars up
    'signal_cellular_alt_outlined':
        0xf38a, // [outline] device — alt, analytics, ascending bars, bar, bars
    'signal_cellular_alt_rounded':
        0xf017c, // [round] device — alt, analytics, ascending bars, bar, bars
    'signal_cellular_alt_sharp':
        0xec9d, // [sharp] device — alt, analytics, ascending bars, bar, bars
    'signal_cellular_connected_no_internet_0_bar':
        0xe5a8, // device — !, 0, 0 bars, alert, attention
    'signal_cellular_connected_no_internet_0_bar_outlined':
        0xf38b, // [outline] device — !, 0, 0 bars, alert, attention
    'signal_cellular_connected_no_internet_0_bar_rounded':
        0xf017d, // [round] device — !, 0, 0 bars, alert, attention
    'signal_cellular_connected_no_internet_0_bar_sharp':
        0xec9e, // [sharp] device — !, 0, 0 bars, alert, attention
    'signal_cellular_connected_no_internet_4_bar':
        0xe5a9, // device — !, 4, 4 bars, alert, attention
    'signal_cellular_connected_no_internet_4_bar_outlined':
        0xf38c, // [outline] device — !, 4, 4 bars, alert, attention
    'signal_cellular_connected_no_internet_4_bar_rounded':
        0xf017e, // [round] device — !, 4, 4 bars, alert, attention
    'signal_cellular_connected_no_internet_4_bar_sharp':
        0xec9f, // [sharp] device — !, 4, 4 bars, alert, attention
    'signal_cellular_no_sim':
        0xe5aa, // device — absent, alert, bar, bars, camera
    'signal_cellular_no_sim_outlined':
        0xf38d, // [outline] device — absent, alert, bar, bars, camera
    'signal_cellular_no_sim_rounded':
        0xf017f, // [round] device — absent, alert, bar, bars, camera
    'signal_cellular_no_sim_sharp':
        0xeca0, // [sharp] device — absent, alert, bar, bars, camera
    'signal_cellular_nodata':
        0xe5ab, // device — antenna, ascending, bars, cell, cellular
    'signal_cellular_nodata_outlined':
        0xf38e, // [outline] device — antenna, ascending, bars, cell, cellular
    'signal_cellular_nodata_rounded':
        0xf0180, // [round] device — antenna, ascending, bars, cell, cellular
    'signal_cellular_nodata_sharp':
        0xeca1, // [sharp] device — antenna, ascending, bars, cell, cellular
    'signal_cellular_null':
        0xe5ac, // device — alert, bars, cell, cellular, communication
    'signal_cellular_null_outlined':
        0xf38f, // [outline] device — alert, bars, cell, cellular, communication
    'signal_cellular_null_rounded':
        0xf0181, // [round] device — alert, bars, cell, cellular, communication
    'signal_cellular_null_sharp':
        0xeca2, // [sharp] device — alert, bars, cell, cellular, communication
    'signal_cellular_off':
        0xe5ad, // device — antenna, bars, cell, cellular, communication
    'signal_cellular_off_outlined':
        0xf390, // [outline] device — antenna, bars, cell, cellular, communication
    'signal_cellular_off_rounded':
        0xf0182, // [round] device — antenna, bars, cell, cellular, communication
    'signal_cellular_off_sharp':
        0xeca3, // [sharp] device — antenna, bars, cell, cellular, communication
    'signal_wifi_0_bar': 0xe5ae, // device — 0, access, arc, bar, cell
    'signal_wifi_0_bar_outlined':
        0xf391, // [outline] device — 0, access, arc, bar, cell
    'signal_wifi_0_bar_rounded':
        0xf0183, // [round] device — 0, access, arc, bar, cell
    'signal_wifi_0_bar_sharp':
        0xeca4, // [sharp] device — 0, access, arc, bar, cell
    'signal_wifi_4_bar': 0xe5af, // device — 4, available, bar, bars, cell
    'signal_wifi_4_bar_lock':
        0xe5b0, // device — 4, access, authentication, bar, bars
    'signal_wifi_4_bar_lock_outlined':
        0xf392, // [outline] device — 4, access, authentication, bar, bars
    'signal_wifi_4_bar_lock_rounded':
        0xf0184, // [round] device — 4, access, authentication, bar, bars
    'signal_wifi_4_bar_lock_sharp':
        0xeca5, // [sharp] device — 4, access, authentication, bar, bars
    'signal_wifi_4_bar_outlined':
        0xf393, // [outline] device — 4, available, bar, bars, cell
    'signal_wifi_4_bar_rounded':
        0xf0185, // [round] device — 4, available, bar, bars, cell
    'signal_wifi_4_bar_sharp':
        0xeca6, // [sharp] device — 4, available, bar, bars, cell
    'signal_wifi_bad': 0xe5b1, // device — access, arc, bad, bar, bars
    'signal_wifi_bad_outlined':
        0xf394, // [outline] device — access, arc, bad, bar, bars
    'signal_wifi_bad_rounded':
        0xf0186, // [round] device — access, arc, bad, bar, bars
    'signal_wifi_bad_sharp':
        0xeca7, // [sharp] device — access, arc, bad, bar, bars
    'signal_wifi_connected_no_internet_4':
        0xe5b2, // device — 4, access, arc, bad, bars
    'signal_wifi_connected_no_internet_4_outlined':
        0xf395, // [outline] device — 4, access, arc, bad, bars
    'signal_wifi_connected_no_internet_4_rounded':
        0xf0187, // [round] device — 4, access, arc, bad, bars
    'signal_wifi_connected_no_internet_4_sharp':
        0xeca8, // [sharp] device — 4, access, arc, bad, bars
    'signal_wifi_off': 0xe5b3, // device — alert, antenna, arcs, bars, cell
    'signal_wifi_off_outlined':
        0xf396, // [outline] device — alert, antenna, arcs, bars, cell
    'signal_wifi_off_rounded':
        0xf0188, // [round] device — alert, antenna, arcs, bars, cell
    'signal_wifi_off_sharp':
        0xeca9, // [sharp] device — alert, antenna, arcs, bars, cell
    'signal_wifi_statusbar_4_bar':
        0xe5b4, // device — 4, available, bar, bars, cell
    'signal_wifi_statusbar_4_bar_outlined':
        0xf397, // [outline] device — 4, available, bar, bars, cell
    'signal_wifi_statusbar_4_bar_rounded':
        0xf0189, // [round] device — 4, available, bar, bars, cell
    'signal_wifi_statusbar_4_bar_sharp':
        0xecaa, // [sharp] device — 4, available, bar, bars, cell
    'signal_wifi_statusbar_connected_no_internet_4':
        0xe5b5, // device — !, 4, alert, attention, caution
    'signal_wifi_statusbar_connected_no_internet_4_outlined':
        0xf398, // [outline] device — !, 4, alert, attention, caution
    'signal_wifi_statusbar_connected_no_internet_4_rounded':
        0xf018a, // [round] device — !, 4, alert, attention, caution
    'signal_wifi_statusbar_connected_no_internet_4_sharp':
        0xecab, // [sharp] device — !, 4, alert, attention, caution
    'signal_wifi_statusbar_null':
        0xe5b6, // device — access, arc, bar, cell, cellular
    'signal_wifi_statusbar_null_outlined':
        0xf399, // [outline] device — access, arc, bar, cell, cellular
    'signal_wifi_statusbar_null_rounded':
        0xf018b, // [round] device — access, arc, bar, cell, cellular
    'signal_wifi_statusbar_null_sharp':
        0xecac, // [sharp] device — access, arc, bar, cell, cellular
    'signpost': 0xf0569, // maps — arrow, bar, destination, direction, guidance
    'signpost_outlined':
        0xf0660, // [outline] maps — arrow, bar, destination, direction, guidance
    'signpost_rounded':
        0xf037f, // [round] maps — arrow, bar, destination, direction, guidance
    'signpost_sharp':
        0xf0472, // [sharp] maps — arrow, bar, destination, direction, guidance
    'sim_card':
        0xe5b7, // hardware — camera, card, carrier, cellular, cellular service
    'sim_card_alert':
        0xe5b8, // notification — !, alert, attention, camera, card
    'sim_card_alert_outlined':
        0xf39a, // [outline] notification — !, alert, attention, camera, card
    'sim_card_alert_rounded':
        0xf018c, // [round] notification — !, alert, attention, camera, card
    'sim_card_alert_sharp':
        0xecad, // [sharp] notification — !, alert, attention, camera, card
    'sim_card_download': 0xe5b9, // device — arrow, camera, card, cellular, chip
    'sim_card_download_outlined':
        0xf39b, // [outline] device — arrow, camera, card, cellular, chip
    'sim_card_download_rounded':
        0xf018d, // [round] device — arrow, camera, card, cellular, chip
    'sim_card_download_sharp':
        0xecae, // [sharp] device — arrow, camera, card, cellular, chip
    'sim_card_outlined':
        0xf39c, // [outline] hardware — camera, card, carrier, cellular, cellular service
    'sim_card_rounded':
        0xf018e, // [round] hardware — camera, card, carrier, cellular, cellular service
    'sim_card_sharp':
        0xecaf, // [sharp] hardware — camera, card, carrier, cellular, cellular service
    'single_bed':
        0xe5ba, // social — accommodations, apartment, bed, bed silhouette, bedroom
    'single_bed_outlined':
        0xf39d, // [outline] social — accommodations, apartment, bed, bed silhouette, bedroom
    'single_bed_rounded':
        0xf018f, // [round] social — accommodations, apartment, bed, bed silhouette, bedroom
    'single_bed_sharp':
        0xecb0, // [sharp] social — accommodations, apartment, bed, bed silhouette, bedroom
    'sip':
        0xe5bb, // communication — VoIP, alphabet, audio call, call, call control
    'sip_outlined':
        0xf39e, // [outline] communication — VoIP, alphabet, audio call, call, call control
    'sip_rounded':
        0xf0190, // [round] communication — VoIP, alphabet, audio call, call, call control
    'sip_sharp':
        0xecb1, // [sharp] communication — VoIP, alphabet, audio call, call, call control
    'six_ft_apart': 0xe02a,
    'six_ft_apart_outlined': 0xee1c,
    'six_ft_apart_rounded': 0xf509,
    'six_ft_apart_sharp': 0xe72a,
    'six_k': 0xe02b, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_outlined':
        0xee1d, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_plus': 0xe02c, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_plus_outlined':
        0xee1e, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_plus_rounded':
        0xf50a, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_plus_sharp':
        0xe72b, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_rounded':
        0xf50b, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_k_sharp':
        0xe72c, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_mp': 0xe02d, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_mp_outlined':
        0xee1f, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_mp_rounded':
        0xf50c, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'six_mp_sharp':
        0xe72d, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'sixteen_mp': 0xe007, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'sixteen_mp_outlined':
        0xedf9, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'sixteen_mp_rounded':
        0xf4e6, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'sixteen_mp_sharp':
        0xe707, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'sixty_fps': 0xe028,
    'sixty_fps_outlined': 0xee1a,
    'sixty_fps_rounded': 0xf507,
    'sixty_fps_select': 0xe029,
    'sixty_fps_select_outlined': 0xee1b,
    'sixty_fps_select_rounded': 0xf508,
    'sixty_fps_select_sharp': 0xe728,
    'sixty_fps_sharp': 0xe729,
    'skateboarding':
        0xe5bc, // social — active, activity, athlete, athletic, board
    'skateboarding_outlined':
        0xf39f, // [outline] social — active, activity, athlete, athletic, board
    'skateboarding_rounded':
        0xf0191, // [round] social — active, activity, athlete, athletic, board
    'skateboarding_sharp':
        0xecb2, // [sharp] social — active, activity, athlete, athletic, board
    'skip_next': 0xe5bd, // av — advance, arrow, audio player, bar, fast forward
    'skip_next_outlined':
        0xf3a0, // [outline] av — advance, arrow, audio player, bar, fast forward
    'skip_next_rounded':
        0xf0192, // [round] av — advance, arrow, audio player, bar, fast forward
    'skip_next_sharp':
        0xecb3, // [sharp] av — advance, arrow, audio player, bar, fast forward
    'skip_previous': 0xe5be, // av — arrow, audio, back, bar, beginning
    'skip_previous_outlined':
        0xf3a1, // [outline] av — arrow, audio, back, bar, beginning
    'skip_previous_rounded':
        0xf0193, // [round] av — arrow, audio, back, bar, beginning
    'skip_previous_sharp':
        0xecb4, // [sharp] av — arrow, audio, back, bar, beginning
    'sledding': 0xe5bf, // social — activity, athlete, athletic, body, child
    'sledding_outlined':
        0xf3a2, // [outline] social — activity, athlete, athletic, body, child
    'sledding_rounded':
        0xf0194, // [round] social — activity, athlete, athletic, body, child
    'sledding_sharp':
        0xecb5, // [sharp] social — activity, athlete, athletic, body, child
    'slideshow':
        0xe5c0, // image — begin, demonstrate, display, entertainment, exhibit
    'slideshow_outlined':
        0xf3a3, // [outline] image — begin, demonstrate, display, entertainment, exhibit
    'slideshow_rounded':
        0xf0195, // [round] image — begin, demonstrate, display, entertainment, exhibit
    'slideshow_sharp':
        0xecb6, // [sharp] image — begin, demonstrate, display, entertainment, exhibit
    'slow_motion_video':
        0xe5c1, // av — adjust speed, arrow, camera, circle, dash
    'slow_motion_video_outlined':
        0xf3a4, // [outline] av — adjust speed, arrow, camera, circle, dash
    'slow_motion_video_rounded':
        0xf0196, // [round] av — adjust speed, arrow, camera, circle, dash
    'slow_motion_video_sharp':
        0xecb7, // [sharp] av — adjust speed, arrow, camera, circle, dash
    'smart_button':
        0xe5c2, // action — ai, appliance, artificial, automated, automatic
    'smart_button_outlined':
        0xf3a5, // [outline] action — ai, appliance, artificial, automated, automatic
    'smart_button_rounded':
        0xf0197, // [round] action — ai, appliance, artificial, automated, automatic
    'smart_button_sharp':
        0xecb8, // [sharp] action — ai, appliance, artificial, automated, automatic
    'smart_display':
        0xe5c3, // hardware — airplay, appliance, automation, base, cast
    'smart_display_outlined':
        0xf3a6, // [outline] hardware — airplay, appliance, automation, base, cast
    'smart_display_rounded':
        0xf0198, // [round] hardware — airplay, appliance, automation, base, cast
    'smart_display_sharp':
        0xecb9, // [sharp] hardware — airplay, appliance, automation, base, cast
    'smart_screen': 0xe5c4, // hardware — Android, OS, airplay, cast, cell
    'smart_screen_outlined':
        0xf3a7, // [outline] hardware — Android, OS, airplay, cast, cell
    'smart_screen_rounded':
        0xf0199, // [round] hardware — Android, OS, airplay, cast, cell
    'smart_screen_sharp':
        0xecba, // [sharp] hardware — Android, OS, airplay, cast, cell
    'smart_toy': 0xe5c5, // hardware — ai, android, assistant, automation, bot
    'smart_toy_outlined':
        0xf3a8, // [outline] hardware — ai, android, assistant, automation, bot
    'smart_toy_rounded':
        0xf019a, // [round] hardware — ai, android, assistant, automation, bot
    'smart_toy_sharp':
        0xecbb, // [sharp] hardware — ai, android, assistant, automation, bot
    'smartphone': 0xe5c6, // hardware — Android, OS, call, cell, cellphone
    'smartphone_outlined':
        0xf3a9, // [outline] hardware — Android, OS, call, cell, cellphone
    'smartphone_rounded':
        0xf019b, // [round] hardware — Android, OS, call, cell, cellphone
    'smartphone_sharp':
        0xecbc, // [sharp] hardware — Android, OS, call, cell, cellphone
    'smoke_free': 0xe5c7, // places — addiction, area, banned, cigar, cigarette
    'smoke_free_outlined':
        0xf3aa, // [outline] places — addiction, area, banned, cigar, cigarette
    'smoke_free_rounded':
        0xf019c, // [round] places — addiction, area, banned, cigar, cigarette
    'smoke_free_sharp':
        0xecbd, // [sharp] places — addiction, area, banned, cigar, cigarette
    'smoking_rooms': 0xe5c8, // places — access, airport, allowed, amenity, area
    'smoking_rooms_outlined':
        0xf3ab, // [outline] places — access, airport, allowed, amenity, area
    'smoking_rooms_rounded':
        0xf019d, // [round] places — access, airport, allowed, amenity, area
    'smoking_rooms_sharp':
        0xecbe, // [sharp] places — access, airport, allowed, amenity, area
    'sms': 0xe5c9, // notification — 3, alert, bubble, chat, communicate
    'sms_failed':
        0xe5ca, // notification — !, alert, announcement, attention, broadcast
    'sms_failed_outlined':
        0xf3ac, // [outline] notification — !, alert, announcement, attention, broadcast
    'sms_failed_rounded':
        0xf019e, // [round] notification — !, alert, announcement, attention, broadcast
    'sms_failed_sharp':
        0xecbf, // [sharp] notification — !, alert, announcement, attention, broadcast
    'sms_outlined':
        0xf3ad, // [outline] notification — 3, alert, bubble, chat, communicate
    'sms_rounded':
        0xf019f, // [round] notification — 3, alert, bubble, chat, communicate
    'sms_sharp':
        0xecc0, // [sharp] notification — 3, alert, bubble, chat, communicate
    'snapchat': 0xf056a,
    'snapchat_outlined': 0xf0661,
    'snapchat_rounded': 0xf0380,
    'snapchat_sharp': 0xf0473,
    'snippet_folder':
        0xe5cb, // file — archive, box, business, categorized, compartment
    'snippet_folder_outlined':
        0xf3ae, // [outline] file — archive, box, business, categorized, compartment
    'snippet_folder_rounded':
        0xf01a0, // [round] file — archive, box, business, categorized, compartment
    'snippet_folder_sharp':
        0xecc1, // [sharp] file — archive, box, business, categorized, compartment
    'snooze': 0xe5cc, // av — alarm, alert, bedtime, bell, clock
    'snooze_outlined':
        0xf3af, // [outline] av — alarm, alert, bedtime, bell, clock
    'snooze_rounded':
        0xf01a1, // [round] av — alarm, alert, bedtime, bell, clock
    'snooze_sharp': 0xecc2, // [sharp] av — alarm, alert, bedtime, bell, clock
    'snowboarding': 0xe5cd, // social — activity, athlete, athletic, board, body
    'snowboarding_outlined':
        0xf3b0, // [outline] social — activity, athlete, athletic, board, body
    'snowboarding_rounded':
        0xf01a2, // [round] social — activity, athlete, athletic, board, body
    'snowboarding_sharp':
        0xecc3, // [sharp] social — activity, athlete, athletic, board, body
    'snowing': 0xf056b, // home — circles, climate, cold, dots, environment
    'snowmobile': 0xe5ce, // maps — activity, adventure, automobile, car, cold
    'snowmobile_outlined':
        0xf3b1, // [outline] maps — activity, adventure, automobile, car, cold
    'snowmobile_rounded':
        0xf01a3, // [round] maps — activity, adventure, automobile, car, cold
    'snowmobile_sharp':
        0xecc4, // [sharp] maps — activity, adventure, automobile, car, cold
    'snowshoeing': 0xe5cf, // social — activity, adventure, body, boots, cold
    'snowshoeing_outlined':
        0xf3b2, // [outline] social — activity, adventure, body, boots, cold
    'snowshoeing_rounded':
        0xf01a4, // [round] social — activity, adventure, body, boots, cold
    'snowshoeing_sharp':
        0xecc5, // [sharp] social — activity, adventure, body, boots, cold
    'soap': 0xe5d0, // places — bar, bath, bathroom, beauty, block
    'soap_outlined':
        0xf3b3, // [outline] places — bar, bath, bathroom, beauty, block
    'soap_rounded':
        0xf01a5, // [round] places — bar, bath, bathroom, beauty, block
    'soap_sharp': 0xecc6, // [sharp] places — bar, bath, bathroom, beauty, block
    'social_distance': 0xe5d1, // social — 6, alert, apart, body, caution
    'social_distance_outlined':
        0xf3b4, // [outline] social — 6, alert, apart, body, caution
    'social_distance_rounded':
        0xf01a6, // [round] social — 6, alert, apart, body, caution
    'social_distance_sharp':
        0xecc7, // [sharp] social — 6, alert, apart, body, caution
    'solar_power':
        0xf07c6, // home — array, clean energy, clean power, eco, electric power
    'solar_power_outlined':
        0xf0716, // [outline] home — array, clean energy, clean power, eco, electric power
    'solar_power_rounded':
        0xf081e, // [round] home — array, clean energy, clean power, eco, electric power
    'solar_power_sharp':
        0xf076e, // [sharp] home — array, clean energy, clean power, eco, electric power
    'sort':
        0xe5d2, // content — alphabetize, arrange, arrow, ascending, categorize
    'sort_by_alpha':
        0xe5d3, // av — a, a to z, alphabet, alphabetical list, alphabetical order
    'sort_by_alpha_outlined':
        0xf3b5, // [outline] av — a, a to z, alphabet, alphabetical list, alphabetical order
    'sort_by_alpha_rounded':
        0xf01a7, // [round] av — a, a to z, alphabet, alphabetical list, alphabetical order
    'sort_by_alpha_sharp':
        0xecc8, // [sharp] av — a, a to z, alphabet, alphabetical list, alphabetical order
    'sort_outlined':
        0xf3b6, // [outline] content — alphabetize, arrange, arrow, ascending, categorize
    'sort_rounded':
        0xf01a8, // [round] content — alphabetize, arrange, arrow, ascending, categorize
    'sort_sharp':
        0xecc9, // [sharp] content — alphabetize, arrange, arrow, ascending, categorize
    'sos': 0xf07c7, // maps — alert, box, communication, danger, distress
    'sos_outlined':
        0xf0717, // [outline] maps — alert, box, communication, danger, distress
    'sos_rounded':
        0xf081f, // [round] maps — alert, box, communication, danger, distress
    'sos_sharp':
        0xf076f, // [sharp] maps — alert, box, communication, danger, distress
    'soup_kitchen': 0xf056c, // maps — aid, assistance, bowl, breakfast, brunch
    'soup_kitchen_outlined':
        0xf0662, // [outline] maps — aid, assistance, bowl, breakfast, brunch
    'soup_kitchen_rounded':
        0xf0381, // [round] maps — aid, assistance, bowl, breakfast, brunch
    'soup_kitchen_sharp':
        0xf0474, // [sharp] maps — aid, assistance, bowl, breakfast, brunch
    'source': 0xe5d4, // action — area, basis, category, code, composer
    'source_outlined':
        0xf3b7, // [outline] action — area, basis, category, code, composer
    'source_rounded':
        0xf01a9, // [round] action — area, basis, category, code, composer
    'source_sharp':
        0xecca, // [sharp] action — area, basis, category, code, composer
    'south': 0xe5d5, // navigation — arrow, arrow down, below, bottom, chevron
    'south_america':
        0xf056d, // social — area, boundary, cartography, continent, continent map
    'south_america_outlined':
        0xf0663, // [outline] social — area, boundary, cartography, continent, continent map
    'south_america_rounded':
        0xf0382, // [round] social — area, boundary, cartography, continent, continent map
    'south_america_sharp':
        0xf0475, // [sharp] social — area, boundary, cartography, continent, continent map
    'south_east':
        0xe5d6, // navigation — arrow, bottom right arrow, box, corner arrow, diagonal arrow
    'south_east_outlined':
        0xf3b8, // [outline] navigation — arrow, bottom right arrow, box, corner arrow, diagonal arrow
    'south_east_rounded':
        0xf01aa, // [round] navigation — arrow, bottom right arrow, box, corner arrow, diagonal arrow
    'south_east_sharp':
        0xeccb, // [sharp] navigation — arrow, bottom right arrow, box, corner arrow, diagonal arrow
    'south_outlined':
        0xf3b9, // [outline] navigation — arrow, arrow down, below, bottom, chevron
    'south_rounded':
        0xf01ab, // [round] navigation — arrow, arrow down, below, bottom, chevron
    'south_sharp':
        0xeccc, // [sharp] navigation — arrow, arrow down, below, bottom, chevron
    'south_west':
        0xe5d7, // navigation — angle, angled arrow, arrow, change direction, diagonal
    'south_west_outlined':
        0xf3ba, // [outline] navigation — angle, angled arrow, arrow, change direction, diagonal
    'south_west_rounded':
        0xf01ac, // [round] navigation — angle, angled arrow, arrow, change direction, diagonal
    'south_west_sharp':
        0xeccd, // [sharp] navigation — angle, angled arrow, arrow, change direction, diagonal
    'spa': 0xe5d8, // places — aromatherapy, bath, beauty, body, flower
    'spa_outlined':
        0xf3bb, // [outline] places — aromatherapy, bath, beauty, body, flower
    'spa_rounded':
        0xf01ad, // [round] places — aromatherapy, bath, beauty, body, flower
    'spa_sharp':
        0xecce, // [sharp] places — aromatherapy, bath, beauty, body, flower
    'space_bar': 0xe5d9, // editor — bar, break, character, document, editor
    'space_bar_outlined':
        0xf3bc, // [outline] editor — bar, break, character, document, editor
    'space_bar_rounded':
        0xf01ae, // [round] editor — bar, break, character, document, editor
    'space_bar_sharp':
        0xeccf, // [sharp] editor — bar, break, character, document, editor
    'space_dashboard':
        0xe5da, // action — analytics, arrangement, blocks, cards, composition
    'space_dashboard_outlined':
        0xf3bd, // [outline] action — analytics, arrangement, blocks, cards, composition
    'space_dashboard_rounded':
        0xf01af, // [round] action — analytics, arrangement, blocks, cards, composition
    'space_dashboard_sharp':
        0xecd0, // [sharp] action — analytics, arrangement, blocks, cards, composition
    'spatial_audio':
        0xf07c8, // action — 3d audio, acoustic, audio, audio effects, audio processing
    'spatial_audio_off':
        0xf07c9, // action — 3d audio off, audio, audio control, audio off, audio options
    'spatial_audio_off_outlined':
        0xf0718, // [outline] action — 3d audio off, audio, audio control, audio off, audio options
    'spatial_audio_off_rounded':
        0xf0820, // [round] action — 3d audio off, audio, audio control, audio off, audio options
    'spatial_audio_off_sharp':
        0xf0770, // [sharp] action — 3d audio off, audio, audio control, audio off, audio options
    'spatial_audio_outlined':
        0xf0719, // [outline] action — 3d audio, acoustic, audio, audio effects, audio processing
    'spatial_audio_rounded':
        0xf0821, // [round] action — 3d audio, acoustic, audio, audio effects, audio processing
    'spatial_audio_sharp':
        0xf0771, // [sharp] action — 3d audio, acoustic, audio, audio effects, audio processing
    'spatial_tracking':
        0xf07ca, // action — 3d, ar, arrow, audio, augmented reality
    'spatial_tracking_outlined':
        0xf071a, // [outline] action — 3d, ar, arrow, audio, augmented reality
    'spatial_tracking_rounded':
        0xf0822, // [round] action — 3d, ar, arrow, audio, augmented reality
    'spatial_tracking_sharp':
        0xf0772, // [sharp] action — 3d, ar, arrow, audio, augmented reality
    'speaker':
        0xe5db, // hardware — acoustic, acoustics, adjust, amplifier, audio
    'speaker_group':
        0xe5dc, // hardware — audio, audio devices, audio group, audio output, box
    'speaker_group_outlined':
        0xf3be, // [outline] hardware — audio, audio devices, audio group, audio output, box
    'speaker_group_rounded':
        0xf01b0, // [round] hardware — audio, audio devices, audio group, audio output, box
    'speaker_group_sharp':
        0xecd1, // [sharp] hardware — audio, audio devices, audio group, audio output, box
    'speaker_notes':
        0xe5dd, // action — annotation, audio, bubble, bullet points, chat
    'speaker_notes_off':
        0xe5de, // action — bubble, cancel, chat, comment, communicate
    'speaker_notes_off_outlined':
        0xf3bf, // [outline] action — bubble, cancel, chat, comment, communicate
    'speaker_notes_off_rounded':
        0xf01b1, // [round] action — bubble, cancel, chat, comment, communicate
    'speaker_notes_off_sharp':
        0xecd2, // [sharp] action — bubble, cancel, chat, comment, communicate
    'speaker_notes_outlined':
        0xf3c0, // [outline] action — annotation, audio, bubble, bullet points, chat
    'speaker_notes_rounded':
        0xf01b2, // [round] action — annotation, audio, bubble, bullet points, chat
    'speaker_notes_sharp':
        0xecd3, // [sharp] action — annotation, audio, bubble, bullet points, chat
    'speaker_outlined':
        0xf3c1, // [outline] hardware — acoustic, acoustics, adjust, amplifier, audio
    'speaker_phone':
        0xe5df, // communication — Android, OS, audio, broadcast, call
    'speaker_phone_outlined':
        0xf3c2, // [outline] communication — Android, OS, audio, broadcast, call
    'speaker_phone_rounded':
        0xf01b3, // [round] communication — Android, OS, audio, broadcast, call
    'speaker_phone_sharp':
        0xecd4, // [sharp] communication — Android, OS, audio, broadcast, call
    'speaker_rounded':
        0xf01b4, // [round] hardware — acoustic, acoustics, adjust, amplifier, audio
    'speaker_sharp':
        0xecd5, // [sharp] hardware — acoustic, acoustics, adjust, amplifier, audio
    'speed': 0xe5e0, // av — acceleration, arrow, automotive, car, circle
    'speed_outlined':
        0xf3c3, // [outline] av — acceleration, arrow, automotive, car, circle
    'speed_rounded':
        0xf01b5, // [round] av — acceleration, arrow, automotive, car, circle
    'speed_sharp':
        0xecd6, // [sharp] av — acceleration, arrow, automotive, car, circle
    'spellcheck': 0xe5e1, // action — a, accuracy, alphabet, approve, character
    'spellcheck_outlined':
        0xf3c4, // [outline] action — a, accuracy, alphabet, approve, character
    'spellcheck_rounded':
        0xf01b6, // [round] action — a, accuracy, alphabet, approve, character
    'spellcheck_sharp':
        0xecd7, // [sharp] action — a, accuracy, alphabet, approve, character
    'splitscreen':
        0xe5e2, // device — arrangement, column, display, divide, dual screen
    'splitscreen_outlined':
        0xf3c5, // [outline] device — arrangement, column, display, divide, dual screen
    'splitscreen_rounded':
        0xf01b7, // [round] device — arrangement, column, display, divide, dual screen
    'splitscreen_sharp':
        0xecd8, // [sharp] device — arrangement, column, display, divide, dual screen
    'spoke':
        0xf056e, // communication — access point, broadcast, center, central point, communicate
    'spoke_outlined':
        0xf0664, // [outline] communication — access point, broadcast, center, central point, communicate
    'spoke_rounded':
        0xf0383, // [round] communication — access point, broadcast, center, central point, communicate
    'spoke_sharp':
        0xf0476, // [sharp] communication — access point, broadcast, center, central point, communicate
    'sports': 0xe5e3, // social — activity, athlete, athletic, blowing, coach
    'sports_bar': 0xe5e4, // places — alcohol, bar, beer, building, casual
    'sports_bar_outlined':
        0xf3c6, // [outline] places — alcohol, bar, beer, building, casual
    'sports_bar_rounded':
        0xf01b8, // [round] places — alcohol, bar, beer, building, casual
    'sports_bar_sharp':
        0xecd9, // [sharp] places — alcohol, bar, beer, building, casual
    'sports_baseball':
        0xe5e5, // social — activity, american sport, athlete, athletic, ball
    'sports_baseball_outlined':
        0xf3c7, // [outline] social — activity, american sport, athlete, athletic, ball
    'sports_baseball_rounded':
        0xf01b9, // [round] social — activity, american sport, athlete, athletic, ball
    'sports_baseball_sharp':
        0xecda, // [sharp] social — activity, american sport, athlete, athletic, ball
    'sports_basketball':
        0xe5e6, // social — activity, arena, athlete, athletic, ball
    'sports_basketball_outlined':
        0xf3c8, // [outline] social — activity, arena, athlete, athletic, ball
    'sports_basketball_rounded':
        0xf01ba, // [round] social — activity, arena, athlete, athletic, ball
    'sports_basketball_sharp':
        0xecdb, // [sharp] social — activity, arena, athlete, athletic, ball
    'sports_cricket':
        0xe5e7, // social — activity, athlete, athletic, athletics, ball
    'sports_cricket_outlined':
        0xf3c9, // [outline] social — activity, athlete, athletic, athletics, ball
    'sports_cricket_rounded':
        0xf01bb, // [round] social — activity, athlete, athletic, athletics, ball
    'sports_cricket_sharp':
        0xecdc, // [sharp] social — activity, athlete, athletic, athletics, ball
    'sports_esports':
        0xe5e8, // social — asset, competitive gaming, computer games, console, console controller
    'sports_esports_outlined':
        0xf3ca, // [outline] social — asset, competitive gaming, computer games, console, console controller
    'sports_esports_rounded':
        0xf01bc, // [round] social — asset, competitive gaming, computer games, console, console controller
    'sports_esports_sharp':
        0xecdd, // [sharp] social — asset, competitive gaming, computer games, console, console controller
    'sports_football':
        0xe5e9, // social — activity, athlete, athletic, ball, championship
    'sports_football_outlined':
        0xf3cb, // [outline] social — activity, athlete, athletic, ball, championship
    'sports_football_rounded':
        0xf01bd, // [round] social — activity, athlete, athletic, ball, championship
    'sports_football_sharp':
        0xecde, // [sharp] social — activity, athlete, athletic, ball, championship
    'sports_golf': 0xe5ea, // social — activity, athlete, athletic, ball, club
    'sports_golf_outlined':
        0xf3cc, // [outline] social — activity, athlete, athletic, ball, club
    'sports_golf_rounded':
        0xf01be, // [round] social — activity, athlete, athletic, ball, club
    'sports_golf_sharp':
        0xecdf, // [sharp] social — activity, athlete, athletic, ball, club
    'sports_gymnastics':
        0xf06c3, // social — active, activity, agility, athlete, athletic
    'sports_gymnastics_outlined':
        0xf06a9, // [outline] social — active, activity, agility, athlete, athletic
    'sports_gymnastics_rounded':
        0xf06d0, // [round] social — active, activity, agility, athlete, athletic
    'sports_gymnastics_sharp':
        0xf06b6, // [sharp] social — active, activity, agility, athlete, athletic
    'sports_handball':
        0xe5eb, // social — activity, athlete, athletic, athletic event, athletics
    'sports_handball_outlined':
        0xf3cd, // [outline] social — activity, athlete, athletic, athletic event, athletics
    'sports_handball_rounded':
        0xf01bf, // [round] social — activity, athlete, athletic, athletic event, athletics
    'sports_handball_sharp':
        0xece0, // [sharp] social — activity, athlete, athletic, athletic event, athletics
    'sports_hockey':
        0xe5ec, // social — activity, athlete, athletic, athletic activity, athletic game
    'sports_hockey_outlined':
        0xf3ce, // [outline] social — activity, athlete, athletic, athletic activity, athletic game
    'sports_hockey_rounded':
        0xf01c0, // [round] social — activity, athlete, athletic, athletic activity, athletic game
    'sports_hockey_sharp':
        0xece1, // [sharp] social — activity, athlete, athletic, athletic activity, athletic game
    'sports_kabaddi':
        0xe5ed, // social — active, agility, asian, athlete, athletic
    'sports_kabaddi_outlined':
        0xf3cf, // [outline] social — active, agility, asian, athlete, athletic
    'sports_kabaddi_rounded':
        0xf01c1, // [round] social — active, agility, asian, athlete, athletic
    'sports_kabaddi_sharp':
        0xece2, // [sharp] social — active, agility, asian, athlete, athletic
    'sports_martial_arts':
        0xf056f, // social — activity, agility, arts, athlete, athletic
    'sports_martial_arts_outlined':
        0xf0665, // [outline] social — activity, agility, arts, athlete, athletic
    'sports_martial_arts_rounded':
        0xf0384, // [round] social — activity, agility, arts, athlete, athletic
    'sports_martial_arts_sharp':
        0xf0477, // [sharp] social — activity, agility, arts, athlete, athletic
    'sports_mma': 0xe5ee, // social — activity, aggression, arena, arts, athlete
    'sports_mma_outlined':
        0xf3d0, // [outline] social — activity, aggression, arena, arts, athlete
    'sports_mma_rounded':
        0xf01c2, // [round] social — activity, aggression, arena, arts, athlete
    'sports_mma_sharp':
        0xece3, // [sharp] social — activity, aggression, arena, arts, athlete
    'sports_motorsports':
        0xe5ef, // social — activity, athlete, athletic, automobile, automotive
    'sports_motorsports_outlined':
        0xf3d1, // [outline] social — activity, athlete, athletic, automobile, automotive
    'sports_motorsports_rounded':
        0xf01c3, // [round] social — activity, athlete, athletic, automobile, automotive
    'sports_motorsports_sharp':
        0xece4, // [sharp] social — activity, athlete, athletic, automobile, automotive
    'sports_outlined':
        0xf3d2, // [outline] social — activity, athlete, athletic, blowing, coach
    'sports_rounded':
        0xf01c4, // [round] social — activity, athlete, athletic, blowing, coach
    'sports_rugby':
        0xe5f0, // social — activity, athlete, athletic, athletic gear, ball
    'sports_rugby_outlined':
        0xf3d3, // [outline] social — activity, athlete, athletic, athletic gear, ball
    'sports_rugby_rounded':
        0xf01c5, // [round] social — activity, athlete, athletic, athletic gear, ball
    'sports_rugby_sharp':
        0xece5, // [sharp] social — activity, athlete, athletic, athletic gear, ball
    'sports_score':
        0xe5f1, // device — athletics, competition, destination, display, final score
    'sports_score_outlined':
        0xf3d4, // [outline] device — athletics, competition, destination, display, final score
    'sports_score_rounded':
        0xf01c6, // [round] device — athletics, competition, destination, display, final score
    'sports_score_sharp':
        0xece6, // [sharp] device — athletics, competition, destination, display, final score
    'sports_sharp':
        0xece7, // [sharp] social — activity, athlete, athletic, blowing, coach
    'sports_soccer':
        0xe5f2, // social — activity, athlete, athletic, ball, championship
    'sports_soccer_outlined':
        0xf3d5, // [outline] social — activity, athlete, athletic, ball, championship
    'sports_soccer_rounded':
        0xf01c7, // [round] social — activity, athlete, athletic, ball, championship
    'sports_soccer_sharp':
        0xece8, // [sharp] social — activity, athlete, athletic, ball, championship
    'sports_tennis':
        0xe5f3, // social — active, activity, athlete, athletic, ball
    'sports_tennis_outlined':
        0xf3d6, // [outline] social — active, activity, athlete, athletic, ball
    'sports_tennis_rounded':
        0xf01c8, // [round] social — active, activity, athlete, athletic, ball
    'sports_tennis_sharp':
        0xece9, // [sharp] social — active, activity, athlete, athletic, ball
    'sports_volleyball':
        0xe5f4, // social — activity, athlete, athletic, ball, block
    'sports_volleyball_outlined':
        0xf3d7, // [outline] social — activity, athlete, athletic, ball, block
    'sports_volleyball_rounded':
        0xf01c9, // [round] social — activity, athlete, athletic, ball, block
    'sports_volleyball_sharp':
        0xecea, // [sharp] social — activity, athlete, athletic, ball, block
    'square': 0xf0570, // editor — area, block, box, building block, container
    'square_foot':
        0xe5f5, // content — architecture, area, construction, design, diagram
    'square_foot_outlined':
        0xf3d8, // [outline] content — architecture, area, construction, design, diagram
    'square_foot_rounded':
        0xf01ca, // [round] content — architecture, area, construction, design, diagram
    'square_foot_sharp':
        0xeceb, // [sharp] content — architecture, area, construction, design, diagram
    'square_outlined':
        0xf0666, // [outline] editor — area, block, box, building block, container
    'square_rounded':
        0xf0385, // [round] editor — area, block, box, building block, container
    'square_sharp':
        0xf0478, // [sharp] editor — area, block, box, building block, container
    'ssid_chart':
        0xf0571, // device — analysis, analytics, bars, chart, communication
    'ssid_chart_outlined':
        0xf0667, // [outline] device — analysis, analytics, bars, chart, communication
    'ssid_chart_rounded':
        0xf0386, // [round] device — analysis, analytics, bars, chart, communication
    'ssid_chart_sharp':
        0xf0479, // [sharp] device — analysis, analytics, bars, chart, communication
    'stacked_bar_chart':
        0xe5f6, // content — analysis, analytics, bar, bar chart, bars
    'stacked_bar_chart_outlined':
        0xf3d9, // [outline] content — analysis, analytics, bar, bar chart, bars
    'stacked_bar_chart_rounded':
        0xf01cb, // [round] content — analysis, analytics, bar, bar chart, bars
    'stacked_bar_chart_sharp':
        0xecec, // [sharp] content — analysis, analytics, bar, bar chart, bars
    'stacked_line_chart':
        0xe5f7, // editor — analysis, analytics, area chart, business, chart
    'stacked_line_chart_outlined':
        0xf3da, // [outline] editor — analysis, analytics, area chart, business, chart
    'stacked_line_chart_rounded':
        0xf01cc, // [round] editor — analysis, analytics, area chart, business, chart
    'stacked_line_chart_sharp':
        0xeced, // [sharp] editor — analysis, analytics, area chart, business, chart
    'stadium':
        0xf0572, // maps — activity, amphitheater, architecture, arena, audience
    'stadium_outlined':
        0xf0668, // [outline] maps — activity, amphitheater, architecture, arena, audience
    'stadium_rounded':
        0xf0387, // [round] maps — activity, amphitheater, architecture, arena, audience
    'stadium_sharp':
        0xf047a, // [sharp] maps — activity, amphitheater, architecture, arena, audience
    'stairs':
        0xe5f8, // places — abstract, access, architecture, ascending, building
    'stairs_outlined':
        0xf3db, // [outline] places — abstract, access, architecture, ascending, building
    'stairs_rounded':
        0xf01cd, // [round] places — abstract, access, architecture, ascending, building
    'stairs_sharp':
        0xecee, // [sharp] places — abstract, access, architecture, ascending, building
    'star':
        0xe5f9, // toggle — add to favorite, best, bookmark, empty, empty star
    'star_border':
        0xe5fa, // toggle — add to favorite, best, bookmark, empty, empty star
    'star_border_outlined':
        0xf3dc, // [outline] toggle — add to favorite, best, bookmark, empty, empty star
    'star_border_purple500':
        0xe5fb, // toggle — 500, add to favorite, best, bookmark, empty
    'star_border_purple500_outlined':
        0xf3dd, // [outline] toggle — 500, add to favorite, best, bookmark, empty
    'star_border_purple500_rounded':
        0xf01ce, // [round] toggle — 500, add to favorite, best, bookmark, empty
    'star_border_purple500_sharp':
        0xecef, // [sharp] toggle — 500, add to favorite, best, bookmark, empty
    'star_border_rounded':
        0xf01cf, // [round] toggle — add to favorite, best, bookmark, empty, empty star
    'star_border_sharp':
        0xecf0, // [sharp] toggle — add to favorite, best, bookmark, empty, empty star
    'star_half':
        0xe5fc, // toggle — achievement, assessment, bookmark, completion, evaluation
    'star_half_outlined':
        0xf3de, // [outline] toggle — achievement, assessment, bookmark, completion, evaluation
    'star_half_rounded':
        0xf01d0, // [round] toggle — achievement, assessment, bookmark, completion, evaluation
    'star_half_sharp':
        0xecf1, // [sharp] toggle — achievement, assessment, bookmark, completion, evaluation
    'star_outline':
        0xe5fd, // toggle — add to favorite, bookmark, empty, empty star, favorite
    'star_outline_outlined':
        0xf3df, // [outline] toggle — add to favorite, bookmark, empty, empty star, favorite
    'star_outline_rounded':
        0xf01d1, // [round] toggle — add to favorite, bookmark, empty, empty star, favorite
    'star_outline_sharp':
        0xecf2, // [sharp] toggle — add to favorite, bookmark, empty, empty star, favorite
    'star_outlined':
        0xf3e0, // [outline] toggle — add to favorite, best, bookmark, empty, empty star
    'star_purple500':
        0xe5fe, // toggle — 500, add to favorite, best, bookmark, empty
    'star_purple500_outlined':
        0xf3e1, // [outline] toggle — 500, add to favorite, best, bookmark, empty
    'star_purple500_rounded':
        0xf01d2, // [round] toggle — 500, add to favorite, best, bookmark, empty
    'star_purple500_sharp':
        0xecf3, // [sharp] toggle — 500, add to favorite, best, bookmark, empty
    'star_rate':
        0xe5ff, // action — achievement, assessment, award, bookmark, celestial
    'star_rate_outlined':
        0xf3e2, // [outline] action — achievement, assessment, award, bookmark, celestial
    'star_rate_rounded':
        0xf01d3, // [round] action — achievement, assessment, award, bookmark, celestial
    'star_rate_sharp':
        0xecf4, // [sharp] action — achievement, assessment, award, bookmark, celestial
    'star_rounded':
        0xf01d4, // [round] toggle — add to favorite, best, bookmark, empty, empty star
    'star_sharp':
        0xecf5, // [sharp] toggle — add to favorite, best, bookmark, empty, empty star
    'stars': 0xe600, // action — achievement, alert, badge, bookmark, bright
    'stars_outlined':
        0xf3e3, // [outline] action — achievement, alert, badge, bookmark, bright
    'stars_rounded':
        0xf01d5, // [round] action — achievement, alert, badge, bookmark, bright
    'stars_sharp':
        0xecf6, // [sharp] action — achievement, alert, badge, bookmark, bright
    'start': 0xf0573, // hardware — arrow, audio, begin, continue, enter
    'start_outlined':
        0xf0669, // [outline] hardware — arrow, audio, begin, continue, enter
    'start_rounded':
        0xf0388, // [round] hardware — arrow, audio, begin, continue, enter
    'start_sharp':
        0xf047b, // [sharp] hardware — arrow, audio, begin, continue, enter
    'stay_current_landscape':
        0xe601, // communication — Android, OS, current, device, device display
    'stay_current_landscape_outlined':
        0xf3e4, // [outline] communication — Android, OS, current, device, device display
    'stay_current_landscape_rounded':
        0xf01d6, // [round] communication — Android, OS, current, device, device display
    'stay_current_landscape_sharp':
        0xecf7, // [sharp] communication — Android, OS, current, device, device display
    'stay_current_portrait':
        0xe602, // communication — Android, OS, call, cell, cellphone
    'stay_current_portrait_outlined':
        0xf3e5, // [outline] communication — Android, OS, call, cell, cellphone
    'stay_current_portrait_rounded':
        0xf01d7, // [round] communication — Android, OS, call, cell, cellphone
    'stay_current_portrait_sharp':
        0xecf8, // [sharp] communication — Android, OS, call, cell, cellphone
    'stay_primary_landscape':
        0xe603, // communication — Android, OS, current, device, device display
    'stay_primary_landscape_outlined':
        0xf3e6, // [outline] communication — Android, OS, current, device, device display
    'stay_primary_landscape_rounded':
        0xf01d8, // [round] communication — Android, OS, current, device, device display
    'stay_primary_landscape_sharp':
        0xecf9, // [sharp] communication — Android, OS, current, device, device display
    'stay_primary_portrait':
        0xe604, // communication — !, Android, OS, alert, attention
    'stay_primary_portrait_outlined':
        0xf3e7, // [outline] communication — !, Android, OS, alert, attention
    'stay_primary_portrait_rounded':
        0xf01d9, // [round] communication — !, Android, OS, alert, attention
    'stay_primary_portrait_sharp':
        0xecfa, // [sharp] communication — !, Android, OS, alert, attention
    'sticky_note_2':
        0xe605, // action — 2, angle, bookmark, communication, corner
    'sticky_note_2_outlined':
        0xf3e8, // [outline] action — 2, angle, bookmark, communication, corner
    'sticky_note_2_rounded':
        0xf01da, // [round] action — 2, angle, bookmark, communication, corner
    'sticky_note_2_sharp':
        0xecfb, // [sharp] action — 2, angle, bookmark, communication, corner
    'stop': 0xe606, // av — audio, block, close, command, control panel
    'stop_circle': 0xe607, // av — audio, block, cancel, caution, circle
    'stop_circle_outlined':
        0xf3e9, // [outline] av — audio, block, cancel, caution, circle
    'stop_circle_rounded':
        0xf01db, // [round] av — audio, block, cancel, caution, circle
    'stop_circle_sharp':
        0xecfc, // [sharp] av — audio, block, cancel, caution, circle
    'stop_outlined':
        0xf3ea, // [outline] av — audio, block, close, command, control panel
    'stop_rounded':
        0xf01dc, // [round] av — audio, block, close, command, control panel
    'stop_screen_share':
        0xe608, // communication — Android, OS, arrow, cast, chrome
    'stop_screen_share_outlined':
        0xf3eb, // [outline] communication — Android, OS, arrow, cast, chrome
    'stop_screen_share_rounded':
        0xf01dd, // [round] communication — Android, OS, arrow, cast, chrome
    'stop_screen_share_sharp':
        0xecfd, // [sharp] communication — Android, OS, arrow, cast, chrome
    'stop_sharp':
        0xecfe, // [sharp] av — audio, block, close, command, control panel
    'storage': 0xe609, // device — archive, backup, boxes, capacity, cloud
    'storage_outlined':
        0xf3ec, // [outline] device — archive, backup, boxes, capacity, cloud
    'storage_rounded':
        0xf01de, // [round] device — archive, backup, boxes, capacity, cloud
    'storage_sharp':
        0xecff, // [sharp] device — archive, backup, boxes, capacity, cloud
    'store': 0xe60a, // action — address, aisle, bill, building, business
    'store_mall_directory':
        0xe60b, // maps — address, aisle, building, business, buying
    'store_mall_directory_outlined':
        0xf3ed, // [outline] maps — address, aisle, building, business, buying
    'store_mall_directory_rounded':
        0xf01df, // [round] maps — address, aisle, building, business, buying
    'store_mall_directory_sharp':
        0xed00, // [sharp] maps — address, aisle, building, business, buying
    'store_outlined':
        0xf3ee, // [outline] action — address, aisle, bill, building, business
    'store_rounded':
        0xf01e0, // [round] action — address, aisle, bill, building, business
    'store_sharp':
        0xed01, // [sharp] action — address, aisle, bill, building, business
    'storefront':
        0xe60c, // places — brick and mortar, building, business, buy, buying
    'storefront_outlined':
        0xf3ef, // [outline] places — brick and mortar, building, business, buy, buying
    'storefront_rounded':
        0xf01e1, // [round] places — brick and mortar, building, business, buy, buying
    'storefront_sharp':
        0xed02, // [sharp] places — brick and mortar, building, business, buy, buying
    'storm': 0xe60d, // device — abstract, alert, angular, bad weather, bolt
    'storm_outlined':
        0xf3f0, // [outline] device — abstract, alert, angular, bad weather, bolt
    'storm_rounded':
        0xf01e2, // [round] device — abstract, alert, angular, bad weather, bolt
    'storm_sharp':
        0xed03, // [sharp] device — abstract, alert, angular, bad weather, bolt
    'straight': 0xf0574, // maps — abstract, abstract shape, arrow, arrows, bar
    'straight_outlined':
        0xf066a, // [outline] maps — abstract, abstract shape, arrow, arrows, bar
    'straight_rounded':
        0xf0389, // [round] maps — abstract, abstract shape, arrow, arrows, bar
    'straight_sharp':
        0xf047c, // [sharp] maps — abstract, abstract shape, arrow, arrows, bar
    'straighten': 0xe60e, // image — adjust, align, angle, arrangement, bend
    'straighten_outlined':
        0xf3f1, // [outline] image — adjust, align, angle, arrangement, bend
    'straighten_rounded':
        0xf01e3, // [round] image — adjust, align, angle, arrangement, bend
    'straighten_sharp':
        0xed04, // [sharp] image — adjust, align, angle, arrangement, bend
    'stream':
        0xe60f, // content — abstract, broadcast, cast, communication, connected
    'stream_outlined':
        0xf3f2, // [outline] content — abstract, broadcast, cast, communication, connected
    'stream_rounded':
        0xf01e4, // [round] content — abstract, broadcast, cast, communication, connected
    'stream_sharp':
        0xed05, // [sharp] content — abstract, broadcast, cast, communication, connected
    'streetview':
        0xe610, // maps — 360 degrees, angle, camera, environment, explore
    'streetview_outlined':
        0xf3f3, // [outline] maps — 360 degrees, angle, camera, environment, explore
    'streetview_rounded':
        0xf01e5, // [round] maps — 360 degrees, angle, camera, environment, explore
    'streetview_sharp':
        0xed06, // [sharp] maps — 360 degrees, angle, camera, environment, explore
    'strikethrough_s':
        0xe611, // editor — alphabet, character, correction, cross, cross out
    'strikethrough_s_outlined':
        0xf3f4, // [outline] editor — alphabet, character, correction, cross, cross out
    'strikethrough_s_rounded':
        0xf01e6, // [round] editor — alphabet, character, correction, cross, cross out
    'strikethrough_s_sharp':
        0xed07, // [sharp] editor — alphabet, character, correction, cross, cross out
    'stroller': 0xe612, // places — accessibility, accessible, baby, buggy, care
    'stroller_outlined':
        0xf3f5, // [outline] places — accessibility, accessible, baby, buggy, care
    'stroller_rounded':
        0xf01e7, // [round] places — accessibility, accessible, baby, buggy, care
    'stroller_sharp':
        0xed08, // [sharp] places — accessibility, accessible, baby, buggy, care
    'style': 0xe613, // image — adjust, alignment, arrangement, block, booklet
    'style_outlined':
        0xf3f6, // [outline] image — adjust, alignment, arrangement, block, booklet
    'style_rounded':
        0xf01e8, // [round] image — adjust, alignment, arrangement, block, booklet
    'style_sharp':
        0xed09, // [sharp] image — adjust, alignment, arrangement, block, booklet
    'subdirectory_arrow_left':
        0xe614, // navigation — angle, arrow, back, curve, direction
    'subdirectory_arrow_left_outlined':
        0xf3f7, // [outline] navigation — angle, arrow, back, curve, direction
    'subdirectory_arrow_left_rounded':
        0xf01e9, // [round] navigation — angle, arrow, back, curve, direction
    'subdirectory_arrow_left_sharp':
        0xed0a, // [sharp] navigation — angle, arrow, back, curve, direction
    'subdirectory_arrow_right':
        0xe615, // navigation — angle, arrow, bend, continue, corner
    'subdirectory_arrow_right_outlined':
        0xf3f8, // [outline] navigation — angle, arrow, bend, continue, corner
    'subdirectory_arrow_right_rounded':
        0xf01ea, // [round] navigation — angle, arrow, bend, continue, corner
    'subdirectory_arrow_right_sharp':
        0xed0b, // [sharp] navigation — angle, arrow, bend, continue, corner
    'subject':
        0xe616, // action — alignment, answer, assistance, balloon, bubble
    'subject_outlined':
        0xf3f9, // [outline] action — alignment, answer, assistance, balloon, bubble
    'subject_rounded':
        0xf01eb, // [round] action — alignment, answer, assistance, balloon, bubble
    'subject_sharp':
        0xed0c, // [sharp] action — alignment, answer, assistance, balloon, bubble
    'subscript':
        0xe617, // editor — 2, alphanumeric, baseline, character, chemical formula
    'subscript_outlined':
        0xf3fa, // [outline] editor — 2, alphanumeric, baseline, character, chemical formula
    'subscript_rounded':
        0xf01ec, // [round] editor — 2, alphanumeric, baseline, character, chemical formula
    'subscript_sharp':
        0xed0d, // [sharp] editor — 2, alphanumeric, baseline, character, chemical formula
    'subscriptions': 0xe618, // av — abstract, alert, alerts, bell, channel
    'subscriptions_outlined':
        0xf3fb, // [outline] av — abstract, alert, alerts, bell, channel
    'subscriptions_rounded':
        0xf01ed, // [round] av — abstract, alert, alerts, bell, channel
    'subscriptions_sharp':
        0xed0e, // [sharp] av — abstract, alert, alerts, bell, channel
    'subtitles':
        0xe619, // av — accessibility, accessible, audio, caption, captions
    'subtitles_off':
        0xe61a, // action — accessibility, accessibility feature, accessible, audio, caption
    'subtitles_off_outlined':
        0xf3fc, // [outline] action — accessibility, accessibility feature, accessible, audio, caption
    'subtitles_off_rounded':
        0xf01ee, // [round] action — accessibility, accessibility feature, accessible, audio, caption
    'subtitles_off_sharp':
        0xed0f, // [sharp] action — accessibility, accessibility feature, accessible, audio, caption
    'subtitles_outlined':
        0xf3fd, // [outline] av — accessibility, accessible, audio, caption, captions
    'subtitles_rounded':
        0xf01ef, // [round] av — accessibility, accessible, audio, caption, captions
    'subtitles_sharp':
        0xed10, // [sharp] av — accessibility, accessible, audio, caption, captions
    'subway': 0xe61b, // maps — automobile, bike, car, cars, city
    'subway_outlined':
        0xf3fe, // [outline] maps — automobile, bike, car, cars, city
    'subway_rounded':
        0xf01f0, // [round] maps — automobile, bike, car, cars, city
    'subway_sharp': 0xed11, // [sharp] maps — automobile, bike, car, cars, city
    'summarize':
        0xe61c, // device — arrows, aspect ratio, corners, corners out, display
    'summarize_outlined':
        0xf3ff, // [outline] device — arrows, aspect ratio, corners, corners out, display
    'summarize_rounded':
        0xf01f1, // [round] device — arrows, aspect ratio, corners, corners out, display
    'summarize_sharp':
        0xed12, // [sharp] device — arrows, aspect ratio, corners, corners out, display
    'sunny': 0xf0575, // home — astronomy, beam, bright, circle, climate
    'sunny_snowing': 0xf0576, // home — bright, clear, climate, cold, conditions
    'superscript':
        0xe61d, // editor — 2, alphanumeric, calculation, character, digit
    'superscript_outlined':
        0xf400, // [outline] editor — 2, alphanumeric, calculation, character, digit
    'superscript_rounded':
        0xf01f2, // [round] editor — 2, alphanumeric, calculation, character, digit
    'superscript_sharp':
        0xed13, // [sharp] editor — 2, alphanumeric, calculation, character, digit
    'supervised_user_circle':
        0xe61e, // action — account, account settings, avatar, child, circle
    'supervised_user_circle_outlined':
        0xf401, // [outline] action — account, account settings, avatar, child, circle
    'supervised_user_circle_rounded':
        0xf01f3, // [round] action — account, account settings, avatar, child, circle
    'supervised_user_circle_sharp':
        0xed14, // [sharp] action — account, account settings, avatar, child, circle
    'supervisor_account':
        0xe61f, // action — access, account, account settings, admin, administrator
    'supervisor_account_outlined':
        0xf402, // [outline] action — access, account, account settings, admin, administrator
    'supervisor_account_rounded':
        0xf01f4, // [round] action — access, account, account settings, admin, administrator
    'supervisor_account_sharp':
        0xed15, // [sharp] action — access, account, account settings, admin, administrator
    'support': 0xe620, // action — advice, agent, assist, assistance, avatar
    'support_agent':
        0xe621, // notification — advisor, agent, answer, assistance, avatar
    'support_agent_outlined':
        0xf403, // [outline] notification — advisor, agent, answer, assistance, avatar
    'support_agent_rounded':
        0xf01f5, // [round] notification — advisor, agent, answer, assistance, avatar
    'support_agent_sharp':
        0xed16, // [sharp] notification — advisor, agent, answer, assistance, avatar
    'support_outlined':
        0xf404, // [outline] action — advice, agent, assist, assistance, avatar
    'support_rounded':
        0xf01f6, // [round] action — advice, agent, assist, assistance, avatar
    'support_sharp':
        0xed17, // [sharp] action — advice, agent, assist, assistance, avatar
    'surfing': 0xe622, // social — activity, athlete, athletic, beach, board
    'surfing_outlined':
        0xf405, // [outline] social — activity, athlete, athletic, beach, board
    'surfing_rounded':
        0xf01f7, // [round] social — activity, athlete, athletic, beach, board
    'surfing_sharp':
        0xed18, // [sharp] social — activity, athlete, athletic, beach, board
    'surround_sound':
        0xe623, // av — 360 audio, adjustment, audio, audio setup, audio system
    'surround_sound_outlined':
        0xf406, // [outline] av — 360 audio, adjustment, audio, audio setup, audio system
    'surround_sound_rounded':
        0xf01f8, // [round] av — 360 audio, adjustment, audio, audio setup, audio system
    'surround_sound_sharp':
        0xed19, // [sharp] av — 360 audio, adjustment, audio, audio setup, audio system
    'swap_calls':
        0xe624, // communication — arrow, arrow up and down, arrows, bidirectional, calls
    'swap_calls_outlined':
        0xf407, // [outline] communication — arrow, arrow up and down, arrows, bidirectional, calls
    'swap_calls_rounded':
        0xf01f9, // [round] communication — arrow, arrow up and down, arrows, bidirectional, calls
    'swap_calls_sharp':
        0xed1a, // [sharp] communication — arrow, arrow up and down, arrows, bidirectional, calls
    'swap_horiz': 0xe625, // action — alternate, arrow, arrows, back, change
    'swap_horiz_outlined':
        0xf408, // [outline] action — alternate, arrow, arrows, back, change
    'swap_horiz_rounded':
        0xf01fa, // [round] action — alternate, arrow, arrows, back, change
    'swap_horiz_sharp':
        0xed1b, // [sharp] action — alternate, arrow, arrows, back, change
    'swap_horizontal_circle':
        0xe626, // action — alternate, arrow, arrows, back, back and forth
    'swap_horizontal_circle_outlined':
        0xf409, // [outline] action — alternate, arrow, arrows, back, back and forth
    'swap_horizontal_circle_rounded':
        0xf01fb, // [round] action — alternate, arrow, arrows, back, back and forth
    'swap_horizontal_circle_sharp':
        0xed1c, // [sharp] action — alternate, arrow, arrows, back, back and forth
    'swap_vert':
        0xe627, // action — arrow, arrows, bidirectional, connection, direction
    'swap_vert_circle': 0xe628,
    'swap_vert_circle_outlined': 0xf40b,
    'swap_vert_circle_rounded': 0xf01fd,
    'swap_vert_circle_sharp': 0xed1e,
    'swap_vert_outlined':
        0xf40a, // [outline] action — arrow, arrows, bidirectional, connection, direction
    'swap_vert_rounded':
        0xf01fc, // [round] action — arrow, arrows, bidirectional, connection, direction
    'swap_vert_sharp':
        0xed1d, // [sharp] action — arrow, arrows, bidirectional, connection, direction
    'swap_vertical_circle':
        0xe628, // action — arrow, arrows, bidirectional, change, circle
    'swap_vertical_circle_outlined':
        0xf40b, // [outline] action — arrow, arrows, bidirectional, change, circle
    'swap_vertical_circle_rounded':
        0xf01fd, // [round] action — arrow, arrows, bidirectional, change, circle
    'swap_vertical_circle_sharp':
        0xed1e, // [sharp] action — arrow, arrows, bidirectional, change, circle
    'swipe': 0xe629, // action — animation, arrow, arrows, cursor, direction
    'swipe_down':
        0xf0578, // action — arrows, content loading, direction, disable, down
    'swipe_down_alt':
        0xf0577, // action — alt, alternate, arrows, direction, disable
    'swipe_down_alt_outlined':
        0xf066b, // [outline] action — alt, alternate, arrows, direction, disable
    'swipe_down_alt_rounded':
        0xf038a, // [round] action — alt, alternate, arrows, direction, disable
    'swipe_down_alt_sharp':
        0xf047d, // [sharp] action — alt, alternate, arrows, direction, disable
    'swipe_down_outlined':
        0xf066c, // [outline] action — arrows, content loading, direction, disable, down
    'swipe_down_rounded':
        0xf038b, // [round] action — arrows, content loading, direction, disable, down
    'swipe_down_sharp':
        0xf047e, // [sharp] action — arrows, content loading, direction, disable, down
    'swipe_left': 0xf057a, // action — arrow, arrows, back, command, direction
    'swipe_left_alt': 0xf0579, // action — alt, archive, arrow, arrows, delete
    'swipe_left_alt_outlined':
        0xf066d, // [outline] action — alt, archive, arrow, arrows, delete
    'swipe_left_alt_rounded':
        0xf038c, // [round] action — alt, archive, arrow, arrows, delete
    'swipe_left_alt_sharp':
        0xf047f, // [sharp] action — alt, archive, arrow, arrows, delete
    'swipe_left_outlined':
        0xf066e, // [outline] action — arrow, arrows, back, command, direction
    'swipe_left_rounded':
        0xf038d, // [round] action — arrow, arrows, back, command, direction
    'swipe_left_sharp':
        0xf0480, // [sharp] action — arrow, arrows, back, command, direction
    'swipe_outlined':
        0xf40c, // [outline] action — animation, arrow, arrows, cursor, direction
    'swipe_right': 0xf057c, // action — accept, advance, arrow, arrows, command
    'swipe_right_alt': 0xf057b, // action — accept, alt, arrow, arrows, cursor
    'swipe_right_alt_outlined':
        0xf066f, // [outline] action — accept, alt, arrow, arrows, cursor
    'swipe_right_alt_rounded':
        0xf038e, // [round] action — accept, alt, arrow, arrows, cursor
    'swipe_right_alt_sharp':
        0xf0481, // [sharp] action — accept, alt, arrow, arrows, cursor
    'swipe_right_outlined':
        0xf0670, // [outline] action — accept, advance, arrow, arrows, command
    'swipe_right_rounded':
        0xf038f, // [round] action — accept, advance, arrow, arrows, command
    'swipe_right_sharp':
        0xf0482, // [sharp] action — accept, advance, arrow, arrows, command
    'swipe_rounded':
        0xf01fe, // [round] action — animation, arrow, arrows, cursor, direction
    'swipe_sharp':
        0xed1f, // [sharp] action — animation, arrow, arrows, cursor, direction
    'swipe_up': 0xf057e, // action — arc, arrow, arrows, caret, clean
    'swipe_up_alt':
        0xf057d, // action — alt, alternative, alternative swipe, arrow, arrow up
    'swipe_up_alt_outlined':
        0xf0671, // [outline] action — alt, alternative, alternative swipe, arrow, arrow up
    'swipe_up_alt_rounded':
        0xf0390, // [round] action — alt, alternative, alternative swipe, arrow, arrow up
    'swipe_up_alt_sharp':
        0xf0483, // [sharp] action — alt, alternative, alternative swipe, arrow, arrow up
    'swipe_up_outlined':
        0xf0672, // [outline] action — arc, arrow, arrows, caret, clean
    'swipe_up_rounded':
        0xf0391, // [round] action — arc, arrow, arrows, caret, clean
    'swipe_up_sharp':
        0xf0484, // [sharp] action — arc, arrow, arrows, caret, clean
    'swipe_vertical':
        0xf057f, // action — arrows, digital, direction, down, drag
    'swipe_vertical_outlined':
        0xf0673, // [outline] action — arrows, digital, direction, down, drag
    'swipe_vertical_rounded':
        0xf0392, // [round] action — arrows, digital, direction, down, drag
    'swipe_vertical_sharp':
        0xf0485, // [sharp] action — arrows, digital, direction, down, drag
    'switch_access_shortcut':
        0xf0581, // action — access, access point, accessibility, activation, alternative input
    'switch_access_shortcut_add':
        0xf0580, // action — +, access, accessibility, add, arrow
    'switch_access_shortcut_add_outlined':
        0xf0674, // [outline] action — +, access, accessibility, add, arrow
    'switch_access_shortcut_add_rounded':
        0xf0393, // [round] action — +, access, accessibility, add, arrow
    'switch_access_shortcut_add_sharp':
        0xf0486, // [sharp] action — +, access, accessibility, add, arrow
    'switch_access_shortcut_outlined':
        0xf0675, // [outline] action — access, access point, accessibility, activation, alternative input
    'switch_access_shortcut_rounded':
        0xf0394, // [round] action — access, access point, accessibility, activation, alternative input
    'switch_access_shortcut_sharp':
        0xf0487, // [sharp] action — access, access point, accessibility, activation, alternative input
    'switch_account':
        0xe62a, // social — access, access control, account, account management, accounts
    'switch_account_outlined':
        0xf40d, // [outline] social — access, access control, account, account management, accounts
    'switch_account_rounded':
        0xf01ff, // [round] social — access, access control, account, account management, accounts
    'switch_account_sharp':
        0xed20, // [sharp] social — access, access control, account, account management, accounts
    'switch_camera':
        0xe62b, // image — arrow, arrows, back camera, camera, camera direction
    'switch_camera_outlined':
        0xf40e, // [outline] image — arrow, arrows, back camera, camera, camera direction
    'switch_camera_rounded':
        0xf0200, // [round] image — arrow, arrows, back camera, camera, camera direction
    'switch_camera_sharp':
        0xed21, // [sharp] image — arrow, arrows, back camera, camera, camera direction
    'switch_left':
        0xe62c, // navigation — activation, arrows, circle, deactivation, device control
    'switch_left_outlined':
        0xf40f, // [outline] navigation — activation, arrows, circle, deactivation, device control
    'switch_left_rounded':
        0xf0201, // [round] navigation — activation, arrows, circle, deactivation, device control
    'switch_left_sharp':
        0xed22, // [sharp] navigation — activation, arrows, circle, deactivation, device control
    'switch_right':
        0xe62d, // navigation — active, arrow, arrows, configuration, direction
    'switch_right_outlined':
        0xf410, // [outline] navigation — active, arrow, arrows, configuration, direction
    'switch_right_rounded':
        0xf0202, // [round] navigation — active, arrow, arrows, configuration, direction
    'switch_right_sharp':
        0xed23, // [sharp] navigation — active, arrow, arrows, configuration, direction
    'switch_video':
        0xe62e, // image — arrow, arrows, back camera, broadcasting, call
    'switch_video_outlined':
        0xf411, // [outline] image — arrow, arrows, back camera, broadcasting, call
    'switch_video_rounded':
        0xf0203, // [round] image — arrow, arrows, back camera, broadcasting, call
    'switch_video_sharp':
        0xed24, // [sharp] image — arrow, arrows, back camera, broadcasting, call
    'synagogue':
        0xf0582, // maps — architecture, building, church, city, community
    'synagogue_outlined':
        0xf0676, // [outline] maps — architecture, building, church, city, community
    'synagogue_rounded':
        0xf0395, // [round] maps — architecture, building, church, city, community
    'synagogue_sharp':
        0xf0488, // [sharp] maps — architecture, building, church, city, community
    'sync': 0xe62f, // notification — 360, align, around, arrow, arrows
    'sync_alt': 0xe630, // action — alt, arrow, arrows, back and forth, change
    'sync_alt_outlined':
        0xf412, // [outline] action — alt, arrow, arrows, back and forth, change
    'sync_alt_rounded':
        0xf0204, // [round] action — alt, arrow, arrows, back and forth, change
    'sync_alt_sharp':
        0xed25, // [sharp] action — alt, arrow, arrows, back and forth, change
    'sync_disabled':
        0xe631, // notification — 360, around, arrow, arrows, broken arrow
    'sync_disabled_outlined':
        0xf413, // [outline] notification — 360, around, arrow, arrows, broken arrow
    'sync_disabled_rounded':
        0xf0205, // [round] notification — 360, around, arrow, arrows, broken arrow
    'sync_disabled_sharp':
        0xed26, // [sharp] notification — 360, around, arrow, arrows, broken arrow
    'sync_lock':
        0xf0583, // notification — access, access control, around, arrow, arrows
    'sync_lock_outlined':
        0xf0677, // [outline] notification — access, access control, around, arrow, arrows
    'sync_lock_rounded':
        0xf0396, // [round] notification — access, access control, around, arrow, arrows
    'sync_lock_sharp':
        0xf0489, // [sharp] notification — access, access control, around, arrow, arrows
    'sync_outlined':
        0xf414, // [outline] notification — 360, align, around, arrow, arrows
    'sync_problem': 0xe632, // notification — !, 360, alert, around, arrow
    'sync_problem_outlined':
        0xf415, // [outline] notification — !, 360, alert, around, arrow
    'sync_problem_rounded':
        0xf0206, // [round] notification — !, 360, alert, around, arrow
    'sync_problem_sharp':
        0xed27, // [sharp] notification — !, 360, alert, around, arrow
    'sync_rounded':
        0xf0207, // [round] notification — 360, align, around, arrow, arrows
    'sync_sharp':
        0xed28, // [sharp] notification — 360, align, around, arrow, arrows
    'system_security_update':
        0xe633, // device — Android, OS, app install, app promo, arrow
    'system_security_update_good':
        0xe634, // device — Android, OS, approve, approved, cell
    'system_security_update_good_outlined':
        0xf416, // [outline] device — Android, OS, approve, approved, cell
    'system_security_update_good_rounded':
        0xf0208, // [round] device — Android, OS, approve, approved, cell
    'system_security_update_good_sharp':
        0xed29, // [sharp] device — Android, OS, approve, approved, cell
    'system_security_update_outlined':
        0xf417, // [outline] device — Android, OS, app install, app promo, arrow
    'system_security_update_rounded':
        0xf0209, // [round] device — Android, OS, app install, app promo, arrow
    'system_security_update_sharp':
        0xed2a, // [sharp] device — Android, OS, app install, app promo, arrow
    'system_security_update_warning':
        0xe635, // device — !, Android, OS, alert, attention
    'system_security_update_warning_outlined':
        0xf418, // [outline] device — !, Android, OS, alert, attention
    'system_security_update_warning_rounded':
        0xf020a, // [round] device — !, Android, OS, alert, attention
    'system_security_update_warning_sharp':
        0xed2b, // [sharp] device — !, Android, OS, alert, attention
    'system_update':
        0xe636, // notification — Android, OS, app install, app promo, arrow
    'system_update_alt':
        0xe637, // action — arrow, backup, cloud, computer, data transfer
    'system_update_alt_outlined':
        0xf419, // [outline] action — arrow, backup, cloud, computer, data transfer
    'system_update_alt_rounded':
        0xf020b, // [round] action — arrow, backup, cloud, computer, data transfer
    'system_update_alt_sharp':
        0xed2c, // [sharp] action — arrow, backup, cloud, computer, data transfer
    'system_update_outlined':
        0xf41a, // [outline] notification — Android, OS, app install, app promo, arrow
    'system_update_rounded':
        0xf020c, // [round] notification — Android, OS, app install, app promo, arrow
    'system_update_sharp':
        0xed2d, // [sharp] notification — Android, OS, app install, app promo, arrow
    'system_update_tv': 0xe637,
    'system_update_tv_outlined': 0xf419,
    'system_update_tv_rounded': 0xf020b,
    'system_update_tv_sharp': 0xed2c,
    'tab':
        0xe638, // action — add button, add document, add tab, add window, application management
    'tab_outlined':
        0xf41b, // [outline] action — add button, add document, add tab, add window, application management
    'tab_rounded':
        0xf020d, // [round] action — add button, add document, add tab, add window, application management
    'tab_sharp':
        0xed2e, // [sharp] action — add button, add document, add tab, add window, application management
    'tab_unselected':
        0xe639, // action — background, blank, browser, computer, content
    'tab_unselected_outlined':
        0xf41c, // [outline] action — background, blank, browser, computer, content
    'tab_unselected_rounded':
        0xf020e, // [round] action — background, blank, browser, computer, content
    'tab_unselected_sharp':
        0xed2f, // [sharp] action — background, blank, browser, computer, content
    'table_bar': 0xf0584, // search — analysis, analytics, bar, business, cafe
    'table_bar_outlined':
        0xf0678, // [outline] search — analysis, analytics, bar, business, cafe
    'table_bar_rounded':
        0xf0397, // [round] search — analysis, analytics, bar, business, cafe
    'table_bar_sharp':
        0xf048a, // [sharp] search — analysis, analytics, bar, business, cafe
    'table_chart': 0xe63a, // editor — analytics, arrange, bar, bars, business
    'table_chart_outlined':
        0xf41d, // [outline] editor — analytics, arrange, bar, bars, business
    'table_chart_rounded':
        0xf020f, // [round] editor — analytics, arrange, bar, bars, business
    'table_chart_sharp':
        0xed30, // [sharp] editor — analytics, arrange, bar, bars, business
    'table_restaurant':
        0xf0585, // search — bar, bistro, bistro table, book table, booking
    'table_restaurant_outlined':
        0xf0679, // [outline] search — bar, bistro, bistro table, book table, booking
    'table_restaurant_rounded':
        0xf0398, // [round] search — bar, bistro, bistro table, book table, booking
    'table_restaurant_sharp':
        0xf048b, // [sharp] search — bar, bistro, bistro table, book table, booking
    'table_rows':
        0xe63b, // editor — array, background, chart, database, document
    'table_rows_outlined':
        0xf41e, // [outline] editor — array, background, chart, database, document
    'table_rows_rounded':
        0xf0210, // [round] editor — array, background, chart, database, document
    'table_rows_sharp':
        0xed31, // [sharp] editor — array, background, chart, database, document
    'table_view':
        0xe63c, // action — arrangement, cell, chart, columns, data visualization
    'table_view_outlined':
        0xf41f, // [outline] action — arrangement, cell, chart, columns, data visualization
    'table_view_rounded':
        0xf0211, // [round] action — arrangement, cell, chart, columns, data visualization
    'table_view_sharp':
        0xed32, // [sharp] action — arrangement, cell, chart, columns, data visualization
    'tablet': 0xe63d, // hardware — Android, OS, communication, computer, device
    'tablet_android':
        0xe63e, // hardware — OS, android, browsing, communication, computing
    'tablet_android_outlined':
        0xf420, // [outline] hardware — OS, android, browsing, communication, computing
    'tablet_android_rounded':
        0xf0212, // [round] hardware — OS, android, browsing, communication, computing
    'tablet_android_sharp':
        0xed33, // [sharp] hardware — OS, android, browsing, communication, computing
    'tablet_mac': 0xe63f, // hardware — Android, OS, apple, computer, device
    'tablet_mac_outlined':
        0xf421, // [outline] hardware — Android, OS, apple, computer, device
    'tablet_mac_rounded':
        0xf0213, // [round] hardware — Android, OS, apple, computer, device
    'tablet_mac_sharp':
        0xed34, // [sharp] hardware — Android, OS, apple, computer, device
    'tablet_outlined':
        0xf422, // [outline] hardware — Android, OS, communication, computer, device
    'tablet_rounded':
        0xf0214, // [round] hardware — Android, OS, communication, computer, device
    'tablet_sharp':
        0xed35, // [sharp] hardware — Android, OS, communication, computer, device
    'tag':
        0xe640, // content — banner, bookmark, categorize, classification, corner
    'tag_faces': 0xe641, // image — add, character, chat, cheerful, circle
    'tag_faces_outlined':
        0xf423, // [outline] image — add, character, chat, cheerful, circle
    'tag_faces_rounded':
        0xf0215, // [round] image — add, character, chat, cheerful, circle
    'tag_faces_sharp':
        0xed36, // [sharp] image — add, character, chat, cheerful, circle
    'tag_outlined':
        0xf424, // [outline] content — banner, bookmark, categorize, classification, corner
    'tag_rounded':
        0xf0216, // [round] content — banner, bookmark, categorize, classification, corner
    'tag_sharp':
        0xed37, // [sharp] content — banner, bookmark, categorize, classification, corner
    'takeout_dining':
        0xe642, // maps — box, catering, container, cutlery, delivery
    'takeout_dining_outlined':
        0xf425, // [outline] maps — box, catering, container, cutlery, delivery
    'takeout_dining_rounded':
        0xf0217, // [round] maps — box, catering, container, cutlery, delivery
    'takeout_dining_sharp':
        0xed38, // [sharp] maps — box, catering, container, cutlery, delivery
    'tap_and_play':
        0xe643, // notification — Android, OS wifi, broadcast, cast, casting
    'tap_and_play_outlined':
        0xf426, // [outline] notification — Android, OS wifi, broadcast, cast, casting
    'tap_and_play_rounded':
        0xf0218, // [round] notification — Android, OS wifi, broadcast, cast, casting
    'tap_and_play_sharp':
        0xed39, // [sharp] notification — Android, OS wifi, broadcast, cast, casting
    'tapas': 0xe644, // places — app logo, appetizer, book, brand, brunch
    'tapas_outlined':
        0xf427, // [outline] places — app logo, appetizer, book, brand, brunch
    'tapas_rounded':
        0xf0219, // [round] places — app logo, appetizer, book, brand, brunch
    'tapas_sharp':
        0xed3a, // [sharp] places — app logo, appetizer, book, brand, brunch
    'task': 0xe645, // device — accepted, agenda, approve, assignment, box
    'task_alt':
        0xe646, // action — approval, approve, check, checklist, checkmark
    'task_alt_outlined':
        0xf428, // [outline] action — approval, approve, check, checklist, checkmark
    'task_alt_rounded':
        0xf021a, // [round] action — approval, approve, check, checklist, checkmark
    'task_alt_sharp':
        0xed3b, // [sharp] action — approval, approve, check, checklist, checkmark
    'task_outlined':
        0xf429, // [outline] device — accepted, agenda, approve, assignment, box
    'task_rounded':
        0xf021b, // [round] device — accepted, agenda, approve, assignment, box
    'task_sharp':
        0xed3c, // [sharp] device — accepted, agenda, approve, assignment, box
    'taxi_alert': 0xe647, // maps — !, alarm, alert, attention, automobile
    'taxi_alert_outlined':
        0xf42a, // [outline] maps — !, alarm, alert, attention, automobile
    'taxi_alert_rounded':
        0xf021c, // [round] maps — !, alarm, alert, attention, automobile
    'taxi_alert_sharp':
        0xed3d, // [sharp] maps — !, alarm, alert, attention, automobile
    'telegram': 0xf0586,
    'telegram_outlined': 0xf067a,
    'telegram_rounded': 0xf0399,
    'telegram_sharp': 0xf048c,
    'temple_buddhist':
        0xf0587, // maps — architecture, asia, asian, buddha, buddhism
    'temple_buddhist_outlined':
        0xf067b, // [outline] maps — architecture, asia, asian, buddha, buddhism
    'temple_buddhist_rounded':
        0xf039a, // [round] maps — architecture, asia, asian, buddha, buddhism
    'temple_buddhist_sharp':
        0xf048d, // [sharp] maps — architecture, asia, asian, buddha, buddhism
    'temple_hindu':
        0xf0588, // maps — ancient, architecture, asian, building, culture
    'temple_hindu_outlined':
        0xf067c, // [outline] maps — ancient, architecture, asian, building, culture
    'temple_hindu_rounded':
        0xf039b, // [round] maps — ancient, architecture, asian, building, culture
    'temple_hindu_sharp':
        0xf048e, // [sharp] maps — ancient, architecture, asian, building, culture
    'ten_k': 0xe000, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_k_outlined':
        0xedf2, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_k_rounded':
        0xf4df, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_k_sharp':
        0xe700, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_mp': 0xe001, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_mp_outlined':
        0xedf3, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_mp_rounded':
        0xf4e0, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'ten_mp_sharp':
        0xe701, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'terminal':
        0xf0589, // action — IT, administration, angle brackets, code, coding
    'terminal_outlined':
        0xf067d, // [outline] action — IT, administration, angle brackets, code, coding
    'terminal_rounded':
        0xf039c, // [round] action — IT, administration, angle brackets, code, coding
    'terminal_sharp':
        0xf048f, // [sharp] action — IT, administration, angle brackets, code, coding
    'terrain': 0xe648, // maps — chart, contour, diagram, elevation, environment
    'terrain_outlined':
        0xf42b, // [outline] maps — chart, contour, diagram, elevation, environment
    'terrain_rounded':
        0xf021d, // [round] maps — chart, contour, diagram, elevation, environment
    'terrain_sharp':
        0xed3e, // [sharp] maps — chart, contour, diagram, elevation, environment
    'text_decrease':
        0xf058a, // editor — -, a, accessibility, alphabet, character
    'text_decrease_outlined':
        0xf067e, // [outline] editor — -, a, accessibility, alphabet, character
    'text_decrease_rounded':
        0xf039d, // [round] editor — -, a, accessibility, alphabet, character
    'text_decrease_sharp':
        0xf0490, // [sharp] editor — -, a, accessibility, alphabet, character
    'text_fields': 0xe649, // editor — T, add, add text, alphabet, blank
    'text_fields_outlined':
        0xf42c, // [outline] editor — T, add, add text, alphabet, blank
    'text_fields_rounded':
        0xf021e, // [round] editor — T, add, add text, alphabet, blank
    'text_fields_sharp':
        0xed3f, // [sharp] editor — T, add, add text, alphabet, blank
    'text_format':
        0xe64a, // content — align, alignment, alphabet, article, character
    'text_format_outlined':
        0xf42d, // [outline] content — align, alignment, alphabet, article, character
    'text_format_rounded':
        0xf021f, // [round] content — align, alignment, alphabet, article, character
    'text_format_sharp':
        0xed40, // [sharp] content — align, alignment, alphabet, article, character
    'text_increase':
        0xf058b, // editor — +, accessibility, add, adjust, alphabet
    'text_increase_outlined':
        0xf067f, // [outline] editor — +, accessibility, add, adjust, alphabet
    'text_increase_rounded':
        0xf039e, // [round] editor — +, accessibility, add, adjust, alphabet
    'text_increase_sharp':
        0xf0491, // [sharp] editor — +, accessibility, add, adjust, alphabet
    'text_rotate_up':
        0xe64b, // action — A, adjustment, alphabet, arrange, arrow
    'text_rotate_up_outlined':
        0xf42e, // [outline] action — A, adjustment, alphabet, arrange, arrow
    'text_rotate_up_rounded':
        0xf0220, // [round] action — A, adjustment, alphabet, arrange, arrow
    'text_rotate_up_sharp':
        0xed41, // [sharp] action — A, adjustment, alphabet, arrange, arrow
    'text_rotate_vertical':
        0xe64c, // action — A, alignment, alphabet, arrange, arrow
    'text_rotate_vertical_outlined':
        0xf42f, // [outline] action — A, alignment, alphabet, arrange, arrow
    'text_rotate_vertical_rounded':
        0xf0221, // [round] action — A, alignment, alphabet, arrange, arrow
    'text_rotate_vertical_sharp':
        0xed42, // [sharp] action — A, alignment, alphabet, arrange, arrow
    'text_rotation_angledown':
        0xe64d, // action — A, adjust text, align, alignment, alphabet
    'text_rotation_angledown_outlined':
        0xf430, // [outline] action — A, adjust text, align, alignment, alphabet
    'text_rotation_angledown_rounded':
        0xf0222, // [round] action — A, adjust text, align, alignment, alphabet
    'text_rotation_angledown_sharp':
        0xed43, // [sharp] action — A, adjust text, align, alignment, alphabet
    'text_rotation_angleup':
        0xe64e, // action — A, adjustment, alphabet, angle, angleup
    'text_rotation_angleup_outlined':
        0xf431, // [outline] action — A, adjustment, alphabet, angle, angleup
    'text_rotation_angleup_rounded':
        0xf0223, // [round] action — A, adjustment, alphabet, angle, angleup
    'text_rotation_angleup_sharp':
        0xed44, // [sharp] action — A, adjustment, alphabet, angle, angleup
    'text_rotation_down':
        0xe64f, // action — A, adjust, alphabet, arrow, character
    'text_rotation_down_outlined':
        0xf432, // [outline] action — A, adjust, alphabet, arrow, character
    'text_rotation_down_rounded':
        0xf0224, // [round] action — A, adjust, alphabet, arrow, character
    'text_rotation_down_sharp':
        0xed45, // [sharp] action — A, adjust, alphabet, arrow, character
    'text_rotation_none': 0xe650, // action — A, alignment, alphabet, arrow, box
    'text_rotation_none_outlined':
        0xf433, // [outline] action — A, alignment, alphabet, arrow, box
    'text_rotation_none_rounded':
        0xf0225, // [round] action — A, alignment, alphabet, arrow, box
    'text_rotation_none_sharp':
        0xed46, // [sharp] action — A, alignment, alphabet, arrow, box
    'text_snippet':
        0xe651, // file — article, character, communication, content, doc
    'text_snippet_outlined':
        0xf434, // [outline] file — article, character, communication, content, doc
    'text_snippet_rounded':
        0xf0226, // [round] file — article, character, communication, content, doc
    'text_snippet_sharp':
        0xed47, // [sharp] file — article, character, communication, content, doc
    'textsms':
        0xe652, // communication — alert, bubble, chat, comment, communicate
    'textsms_outlined':
        0xf435, // [outline] communication — alert, bubble, chat, comment, communicate
    'textsms_rounded':
        0xf0227, // [round] communication — alert, bubble, chat, comment, communicate
    'textsms_sharp':
        0xed48, // [sharp] communication — alert, bubble, chat, comment, communicate
    'texture':
        0xe653, // image — abstract, appearance, background, bumpy, crosshatch
    'texture_outlined':
        0xf436, // [outline] image — abstract, appearance, background, bumpy, crosshatch
    'texture_rounded':
        0xf0228, // [round] image — abstract, appearance, background, bumpy, crosshatch
    'texture_sharp':
        0xed49, // [sharp] image — abstract, appearance, background, bumpy, crosshatch
    'theater_comedy': 0xe654, // maps — acting, art, broadway, comedian, comedy
    'theater_comedy_outlined':
        0xf437, // [outline] maps — acting, art, broadway, comedian, comedy
    'theater_comedy_rounded':
        0xf0229, // [round] maps — acting, art, broadway, comedian, comedy
    'theater_comedy_sharp':
        0xed4a, // [sharp] maps — acting, art, broadway, comedian, comedy
    'theaters':
        0xe655, // action — box office, cinema, clip, documentary, entertainment
    'theaters_outlined':
        0xf438, // [outline] action — box office, cinema, clip, documentary, entertainment
    'theaters_rounded':
        0xf022a, // [round] action — box office, cinema, clip, documentary, entertainment
    'theaters_sharp':
        0xed4b, // [sharp] action — box office, cinema, clip, documentary, entertainment
    'thermostat':
        0xe656, // device — adjustment, automation, climate, cool, cooling
    'thermostat_auto':
        0xe657, // image — A, adjustment, appliance, auto, automatic
    'thermostat_auto_outlined':
        0xf439, // [outline] image — A, adjustment, appliance, auto, automatic
    'thermostat_auto_rounded':
        0xf022b, // [round] image — A, adjustment, appliance, auto, automatic
    'thermostat_auto_sharp':
        0xed4c, // [sharp] image — A, adjustment, appliance, auto, automatic
    'thermostat_outlined':
        0xf43a, // [outline] device — adjustment, automation, climate, cool, cooling
    'thermostat_rounded':
        0xf022c, // [round] device — adjustment, automation, climate, cool, cooling
    'thermostat_sharp':
        0xed4d, // [sharp] device — adjustment, automation, climate, cool, cooling
    'thirteen_mp': 0xe004, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'thirteen_mp_outlined':
        0xedf6, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'thirteen_mp_rounded':
        0xf4e3, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'thirteen_mp_sharp':
        0xe704, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'thirty_fps': 0xe016,
    'thirty_fps_outlined': 0xee08,
    'thirty_fps_rounded': 0xf4f5,
    'thirty_fps_select': 0xe017,
    'thirty_fps_select_outlined': 0xee09,
    'thirty_fps_select_rounded': 0xf4f6,
    'thirty_fps_select_sharp': 0xe716,
    'thirty_fps_sharp': 0xe717,
    'three_g_mobiledata':
        0xe01a, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_g_mobiledata_outlined':
        0xee0c, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_g_mobiledata_rounded':
        0xf4f9, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_g_mobiledata_sharp':
        0xe71a, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k': 0xe01b, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_outlined':
        0xee0d, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_plus': 0xe01c, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_plus_outlined':
        0xee0e, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_plus_rounded':
        0xf4fa, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_plus_sharp':
        0xe71b, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_rounded':
        0xf4fb, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_k_sharp':
        0xe71c, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_mp': 0xe01d, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_mp_outlined':
        0xee0f, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_mp_rounded':
        0xf4fc, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_mp_sharp':
        0xe71d, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'three_p': 0xe01e,
    'three_p_outlined': 0xee10,
    'three_p_rounded': 0xf4fd,
    'three_p_sharp': 0xe71e,
    'threed_rotation': 0xe019,
    'threed_rotation_outlined': 0xee0b,
    'threed_rotation_rounded': 0xf4f8,
    'threed_rotation_sharp': 0xe719,
    'threesixty': 0xe018,
    'threesixty_outlined': 0xee0a,
    'threesixty_rounded': 0xf4f7,
    'threesixty_sharp': 0xe718,
    'thumb_down':
        0xe658, // action — ate, cancel, disagree, disapproval, dislike
    'thumb_down_alt':
        0xe659, // social — bad, cancel, decline, disagree, disapproval
    'thumb_down_alt_outlined':
        0xf43b, // [outline] social — bad, cancel, decline, disagree, disapproval
    'thumb_down_alt_rounded':
        0xf022d, // [round] social — bad, cancel, decline, disagree, disapproval
    'thumb_down_alt_sharp':
        0xed4e, // [sharp] social — bad, cancel, decline, disagree, disapproval
    'thumb_down_off_alt':
        0xe65a, // action — cancel, disabled, disagree, disapproval, dislike
    'thumb_down_off_alt_outlined':
        0xf43c, // [outline] action — cancel, disabled, disagree, disapproval, dislike
    'thumb_down_off_alt_rounded':
        0xf022e, // [round] action — cancel, disabled, disagree, disapproval, dislike
    'thumb_down_off_alt_sharp':
        0xed4f, // [sharp] action — cancel, disabled, disagree, disapproval, dislike
    'thumb_down_outlined':
        0xf43d, // [outline] action — ate, cancel, disagree, disapproval, dislike
    'thumb_down_rounded':
        0xf022f, // [round] action — ate, cancel, disagree, disapproval, dislike
    'thumb_down_sharp':
        0xed50, // [sharp] action — ate, cancel, disagree, disapproval, dislike
    'thumb_up':
        0xe65b, // action — acknowledgement, agree, approve, choice, confirmation
    'thumb_up_alt':
        0xe65c, // social — acknowledgement, agree, agreed, approve, approved
    'thumb_up_alt_outlined':
        0xf43e, // [outline] social — acknowledgement, agree, agreed, approve, approved
    'thumb_up_alt_rounded':
        0xf0230, // [round] social — acknowledgement, agree, agreed, approve, approved
    'thumb_up_alt_sharp':
        0xed51, // [sharp] social — acknowledgement, agree, agreed, approve, approved
    'thumb_up_off_alt':
        0xe65d, // action — acknowledgement, agree, alt, approve, choice
    'thumb_up_off_alt_outlined':
        0xf43f, // [outline] action — acknowledgement, agree, alt, approve, choice
    'thumb_up_off_alt_rounded':
        0xf0231, // [round] action — acknowledgement, agree, alt, approve, choice
    'thumb_up_off_alt_sharp':
        0xed52, // [sharp] action — acknowledgement, agree, alt, approve, choice
    'thumb_up_outlined':
        0xf440, // [outline] action — acknowledgement, agree, approve, choice, confirmation
    'thumb_up_rounded':
        0xf0232, // [round] action — acknowledgement, agree, approve, choice, confirmation
    'thumb_up_sharp':
        0xed53, // [sharp] action — acknowledgement, agree, approve, choice, confirmation
    'thumbs_up_down':
        0xe65e, // action — agree, approval, comparison, contrast, decision
    'thumbs_up_down_outlined':
        0xf441, // [outline] action — agree, approval, comparison, contrast, decision
    'thumbs_up_down_rounded':
        0xf0233, // [round] action — agree, approval, comparison, contrast, decision
    'thumbs_up_down_sharp':
        0xed54, // [sharp] action — agree, approval, comparison, contrast, decision
    'thunderstorm':
        0xf07cb, // social — alert, atmosphere, bad weather, bolt, climate
    'thunderstorm_outlined':
        0xf071b, // [outline] social — alert, atmosphere, bad weather, bolt, climate
    'thunderstorm_rounded':
        0xf0823, // [round] social — alert, atmosphere, bad weather, bolt, climate
    'thunderstorm_sharp':
        0xf0773, // [sharp] social — alert, atmosphere, bad weather, bolt, climate
    'tiktok': 0xf058c,
    'tiktok_outlined': 0xf0680,
    'tiktok_rounded': 0xf039f,
    'tiktok_sharp': 0xf0492,
    'time_to_leave':
        0xe65f, // notification — auto, automobile, automotive, car, car symbol
    'time_to_leave_outlined':
        0xf442, // [outline] notification — auto, automobile, automotive, car, car symbol
    'time_to_leave_rounded':
        0xf0234, // [round] notification — auto, automobile, automotive, car, car symbol
    'time_to_leave_sharp':
        0xed55, // [sharp] notification — auto, automobile, automotive, car, car symbol
    'timelapse':
        0xe660, // image — accelerate, adjustment, arrow, camera, capture
    'timelapse_outlined':
        0xf443, // [outline] image — accelerate, adjustment, arrow, camera, capture
    'timelapse_rounded':
        0xf0235, // [round] image — accelerate, adjustment, arrow, camera, capture
    'timelapse_sharp':
        0xed56, // [sharp] image — accelerate, adjustment, arrow, camera, capture
    'timeline': 0xe661, // action — chart, chronological, dates, diagram, dots
    'timeline_outlined':
        0xf444, // [outline] action — chart, chronological, dates, diagram, dots
    'timeline_rounded':
        0xf0236, // [round] action — chart, chronological, dates, diagram, dots
    'timeline_sharp':
        0xed57, // [sharp] action — chart, chronological, dates, diagram, dots
    'timer': 0xe662, // image — alarm, alert, appointment, bell, chronometer
    'timer_10': 0xe663, // image — 10, alarm, alert, bell, camera
    'timer_10_outlined':
        0xf445, // [outline] image — 10, alarm, alert, bell, camera
    'timer_10_rounded':
        0xf0237, // [round] image — 10, alarm, alert, bell, camera
    'timer_10_select':
        0xe664, // device — 10, adjustment, alphabet, analog, camera
    'timer_10_select_outlined':
        0xf446, // [outline] device — 10, adjustment, alphabet, analog, camera
    'timer_10_select_rounded':
        0xf0238, // [round] device — 10, adjustment, alphabet, analog, camera
    'timer_10_select_sharp':
        0xed58, // [sharp] device — 10, adjustment, alphabet, analog, camera
    'timer_10_sharp': 0xed59, // [sharp] image — 10, alarm, alert, bell, camera
    'timer_3': 0xe665, // image — 3, circle, clock, countdown, digit
    'timer_3_outlined':
        0xf447, // [outline] image — 3, circle, clock, countdown, digit
    'timer_3_rounded':
        0xf0239, // [round] image — 3, circle, clock, countdown, digit
    'timer_3_select': 0xe666, // device — 3, alphabet, camera, character, choose
    'timer_3_select_outlined':
        0xf448, // [outline] device — 3, alphabet, camera, character, choose
    'timer_3_select_rounded':
        0xf023a, // [round] device — 3, alphabet, camera, character, choose
    'timer_3_select_sharp':
        0xed5a, // [sharp] device — 3, alphabet, camera, character, choose
    'timer_3_sharp':
        0xed5b, // [sharp] image — 3, circle, clock, countdown, digit
    'timer_off':
        0xe667, // image — alarm, alarm disabled, alarm off, alert, bell
    'timer_off_outlined':
        0xf449, // [outline] image — alarm, alarm disabled, alarm off, alert, bell
    'timer_off_rounded':
        0xf023b, // [round] image — alarm, alarm disabled, alarm off, alert, bell
    'timer_off_sharp':
        0xed5c, // [sharp] image — alarm, alarm disabled, alarm off, alert, bell
    'timer_outlined':
        0xf44a, // [outline] image — alarm, alert, appointment, bell, chronometer
    'timer_rounded':
        0xf023c, // [round] image — alarm, alert, appointment, bell, chronometer
    'timer_sharp':
        0xed5d, // [sharp] image — alarm, alert, appointment, bell, chronometer
    'tips_and_updates':
        0xf058d, // action — advice, ai, alert, and, announcement
    'tips_and_updates_outlined':
        0xf0681, // [outline] action — advice, ai, alert, and, announcement
    'tips_and_updates_rounded':
        0xf03a0, // [round] action — advice, ai, alert, and, announcement
    'tips_and_updates_sharp':
        0xf0493, // [sharp] action — advice, ai, alert, and, announcement
    'tire_repair':
        0xf06c4, // maps — alert, assistance, auto, automobile, automotive
    'tire_repair_outlined':
        0xf06aa, // [outline] maps — alert, assistance, auto, automobile, automotive
    'tire_repair_rounded':
        0xf06d1, // [round] maps — alert, assistance, auto, automobile, automotive
    'tire_repair_sharp':
        0xf06b7, // [sharp] maps — alert, assistance, auto, automobile, automotive
    'title': 0xe668, // editor — T, alphabet, basic minus, box, character
    'title_outlined':
        0xf44b, // [outline] editor — T, alphabet, basic minus, box, character
    'title_rounded':
        0xf023d, // [round] editor — T, alphabet, basic minus, box, character
    'title_sharp':
        0xed5e, // [sharp] editor — T, alphabet, basic minus, box, character
    'toc':
        0xe669, // action — bullet points, chapter list, chapters, content, document
    'toc_outlined':
        0xf44c, // [outline] action — bullet points, chapter list, chapters, content, document
    'toc_rounded':
        0xf023e, // [round] action — bullet points, chapter list, chapters, content, document
    'toc_sharp':
        0xed5f, // [sharp] action — bullet points, chapter list, chapters, content, document
    'today':
        0xe66a, // action — agenda, appointment, calendar, circle, circle with dot
    'today_outlined':
        0xf44d, // [outline] action — agenda, appointment, calendar, circle, circle with dot
    'today_rounded':
        0xf023f, // [round] action — agenda, appointment, calendar, circle, circle with dot
    'today_sharp':
        0xed60, // [sharp] action — agenda, appointment, calendar, circle, circle with dot
    'toggle_off':
        0xe66b, // toggle — active, choice, circle, configuration, device
    'toggle_off_outlined':
        0xf44e, // [outline] toggle — active, choice, circle, configuration, device
    'toggle_off_rounded':
        0xf0240, // [round] toggle — active, choice, circle, configuration, device
    'toggle_off_sharp':
        0xed61, // [sharp] toggle — active, choice, circle, configuration, device
    'toggle_on':
        0xe66c, // toggle — activate, active, circle, configuration, control on
    'toggle_on_outlined':
        0xf44f, // [outline] toggle — activate, active, circle, configuration, control on
    'toggle_on_rounded':
        0xf0241, // [round] toggle — activate, active, circle, configuration, control on
    'toggle_on_sharp':
        0xed62, // [sharp] toggle — activate, active, circle, configuration, control on
    'token':
        0xf058e, // action — access, access token, account, approval, authentication
    'token_outlined':
        0xf0682, // [outline] action — access, access token, account, approval, authentication
    'token_rounded':
        0xf03a1, // [round] action — access, access token, account, approval, authentication
    'token_sharp':
        0xf0494, // [sharp] action — access, access token, account, approval, authentication
    'toll': 0xe66d, // action — assets, bill, booth, budget, car
    'toll_outlined':
        0xf450, // [outline] action — assets, bill, booth, budget, car
    'toll_rounded':
        0xf0242, // [round] action — assets, bill, booth, budget, car
    'toll_sharp': 0xed63, // [sharp] action — assets, bill, booth, budget, car
    'tonality': 0xe66e, // image — adjust, audio, audio settings, circle, edit
    'tonality_outlined':
        0xf451, // [outline] image — adjust, audio, audio settings, circle, edit
    'tonality_rounded':
        0xf0243, // [round] image — adjust, audio, audio settings, circle, edit
    'tonality_sharp':
        0xed64, // [sharp] image — adjust, audio, audio settings, circle, edit
    'topic': 0xe66f, // file — area, basis, category, concern, context
    'topic_outlined':
        0xf452, // [outline] file — area, basis, category, concern, context
    'topic_rounded':
        0xf0244, // [round] file — area, basis, category, concern, context
    'topic_sharp':
        0xed65, // [sharp] file — area, basis, category, concern, context
    'tornado': 0xf07cc, // social — alert, atmospheric, climate, cone, crisis
    'tornado_outlined':
        0xf071c, // [outline] social — alert, atmospheric, climate, cone, crisis
    'tornado_rounded':
        0xf0824, // [round] social — alert, atmospheric, climate, cone, crisis
    'tornado_sharp':
        0xf0774, // [sharp] social — alert, atmospheric, climate, cone, crisis
    'touch_app': 0xe670, // action — click, command, cursor, device, digital
    'touch_app_outlined':
        0xf453, // [outline] action — click, command, cursor, device, digital
    'touch_app_rounded':
        0xf0245, // [round] action — click, command, cursor, device, digital
    'touch_app_sharp':
        0xed66, // [sharp] action — click, command, cursor, device, digital
    'tour': 0xe671, // action — assist, assistance, circle, destination, dot
    'tour_outlined':
        0xf454, // [outline] action — assist, assistance, circle, destination, dot
    'tour_rounded':
        0xf0246, // [round] action — assist, assistance, circle, destination, dot
    'tour_sharp':
        0xed67, // [sharp] action — assist, assistance, circle, destination, dot
    'toys':
        0xe672, // hardware — activity, assemble, blocks, building, building blocks
    'toys_outlined':
        0xf455, // [outline] hardware — activity, assemble, blocks, building, building blocks
    'toys_rounded':
        0xf0247, // [round] hardware — activity, assemble, blocks, building, building blocks
    'toys_sharp':
        0xed68, // [sharp] hardware — activity, assemble, blocks, building, building blocks
    'track_changes':
        0xe673, // action — bullseye, changes, circle, collaboration, compare
    'track_changes_outlined':
        0xf456, // [outline] action — bullseye, changes, circle, collaboration, compare
    'track_changes_rounded':
        0xf0248, // [round] action — bullseye, changes, circle, collaboration, compare
    'track_changes_sharp':
        0xed69, // [sharp] action — bullseye, changes, circle, collaboration, compare
    'traffic': 0xe674, // maps — accident, barrier, block, car, caution
    'traffic_outlined':
        0xf457, // [outline] maps — accident, barrier, block, car, caution
    'traffic_rounded':
        0xf0249, // [round] maps — accident, barrier, block, car, caution
    'traffic_sharp':
        0xed6a, // [sharp] maps — accident, barrier, block, car, caution
    'train': 0xe675, // maps — automobile, car, cargo, cars, commute
    'train_outlined':
        0xf458, // [outline] maps — automobile, car, cargo, cars, commute
    'train_rounded':
        0xf024a, // [round] maps — automobile, car, cargo, cars, commute
    'train_sharp':
        0xed6b, // [sharp] maps — automobile, car, cargo, cars, commute
    'tram': 0xe676, // maps — automobile, cable car, car, cars, city
    'tram_outlined':
        0xf459, // [outline] maps — automobile, cable car, car, cars, city
    'tram_rounded':
        0xf024b, // [round] maps — automobile, cable car, car, cars, city
    'tram_sharp':
        0xed6c, // [sharp] maps — automobile, cable car, car, cars, city
    'transcribe': 0xf07cd, // action — ai, analysis, assistant, audio, automatic
    'transcribe_outlined':
        0xf071d, // [outline] action — ai, analysis, assistant, audio, automatic
    'transcribe_rounded':
        0xf0825, // [round] action — ai, analysis, assistant, audio, automatic
    'transcribe_sharp':
        0xf0775, // [sharp] action — ai, analysis, assistant, audio, automatic
    'transfer_within_a_station': 0xe677, // maps — a, arrow, arrows, body, bus
    'transfer_within_a_station_outlined':
        0xf45a, // [outline] maps — a, arrow, arrows, body, bus
    'transfer_within_a_station_rounded':
        0xf024c, // [round] maps — a, arrow, arrows, body, bus
    'transfer_within_a_station_sharp':
        0xed6d, // [sharp] maps — a, arrow, arrows, body, bus
    'transform': 0xe678, // image — adjust, alter, anchors, aspect ratio, box
    'transform_outlined':
        0xf45b, // [outline] image — adjust, alter, anchors, aspect ratio, box
    'transform_rounded':
        0xf024d, // [round] image — adjust, alter, anchors, aspect ratio, box
    'transform_sharp':
        0xed6e, // [sharp] image — adjust, alter, anchors, aspect ratio, box
    'transgender':
        0xe679, // social — arrow, biological sex, circle, community, cross
    'transgender_outlined':
        0xf45c, // [outline] social — arrow, biological sex, circle, community, cross
    'transgender_rounded':
        0xf024e, // [round] social — arrow, biological sex, circle, community, cross
    'transgender_sharp':
        0xed6f, // [sharp] social — arrow, biological sex, circle, community, cross
    'transit_enterexit': 0xe67a, // maps — access, arrival, arrow, bus, commute
    'transit_enterexit_outlined':
        0xf45d, // [outline] maps — access, arrival, arrow, bus, commute
    'transit_enterexit_rounded':
        0xf024f, // [round] maps — access, arrival, arrow, bus, commute
    'transit_enterexit_sharp':
        0xed70, // [sharp] maps — access, arrival, arrow, bus, commute
    'translate': 0xe67b, // action — arrow, bidirectional, bubble, change, chat
    'translate_outlined':
        0xf45e, // [outline] action — arrow, bidirectional, bubble, change, chat
    'translate_rounded':
        0xf0250, // [round] action — arrow, bidirectional, bubble, change, chat
    'translate_sharp':
        0xed71, // [sharp] action — arrow, bidirectional, bubble, change, chat
    'travel_explore':
        0xe67c, // social — adventure, browser, circle, destination, discover
    'travel_explore_outlined':
        0xf45f, // [outline] social — adventure, browser, circle, destination, discover
    'travel_explore_rounded':
        0xf0251, // [round] social — adventure, browser, circle, destination, discover
    'travel_explore_sharp':
        0xed72, // [sharp] social — adventure, browser, circle, destination, discover
    'trending_down':
        0xe67d, // action — analysis, analytics, arrow, arrow down, business
    'trending_down_outlined':
        0xf460, // [outline] action — analysis, analytics, arrow, arrow down, business
    'trending_down_rounded':
        0xf0252, // [round] action — analysis, analytics, arrow, arrow down, business
    'trending_down_sharp':
        0xed73, // [sharp] action — analysis, analytics, arrow, arrow down, business
    'trending_flat': 0xe67e, // action — arrow, average, change, chart, constant
    'trending_flat_outlined':
        0xf461, // [outline] action — arrow, average, change, chart, constant
    'trending_flat_rounded':
        0xf0253, // [round] action — arrow, average, change, chart, constant
    'trending_flat_sharp':
        0xed74, // [sharp] action — arrow, average, change, chart, constant
    'trending_neutral': 0xe67e,
    'trending_neutral_outlined': 0xf461,
    'trending_neutral_rounded': 0xf0253,
    'trending_neutral_sharp': 0xed74,
    'trending_up':
        0xe67f, // action — analysis, analytics, arrow, ascending, business
    'trending_up_outlined':
        0xf462, // [outline] action — analysis, analytics, arrow, ascending, business
    'trending_up_rounded':
        0xf0254, // [round] action — analysis, analytics, arrow, ascending, business
    'trending_up_sharp':
        0xed75, // [sharp] action — analysis, analytics, arrow, ascending, business
    'trip_origin':
        0xe680, // maps — address, beginning, circle, departure, destination
    'trip_origin_outlined':
        0xf463, // [outline] maps — address, beginning, circle, departure, destination
    'trip_origin_rounded':
        0xf0255, // [round] maps — address, beginning, circle, departure, destination
    'trip_origin_sharp':
        0xed76, // [sharp] maps — address, beginning, circle, departure, destination
    'trolley': 0xf0878, // hardware — add to cart, bag, basket, buy, carry
    'troubleshoot':
        0xf07ce, // action — adjust, analytics, chart, cogs, configure
    'troubleshoot_outlined':
        0xf071e, // [outline] action — adjust, analytics, chart, cogs, configure
    'troubleshoot_rounded':
        0xf0826, // [round] action — adjust, analytics, chart, cogs, configure
    'troubleshoot_sharp':
        0xf0776, // [sharp] action — adjust, analytics, chart, cogs, configure
    'try_sms_star': 0xe681,
    'try_sms_star_outlined': 0xf464,
    'try_sms_star_rounded': 0xf0256,
    'try_sms_star_sharp': 0xed77,
    'tsunami':
        0xf07cf, // social — alert, breaking wave, climate, coastal, cresting wave
    'tsunami_outlined':
        0xf071f, // [outline] social — alert, breaking wave, climate, coastal, cresting wave
    'tsunami_rounded':
        0xf0827, // [round] social — alert, breaking wave, climate, coastal, cresting wave
    'tsunami_sharp':
        0xf0777, // [sharp] social — alert, breaking wave, climate, coastal, cresting wave
    'tty': 0xe682, // places — accessibility, aid, assistance, audio, call
    'tty_outlined':
        0xf465, // [outline] places — accessibility, aid, assistance, audio, call
    'tty_rounded':
        0xf0257, // [round] places — accessibility, aid, assistance, audio, call
    'tty_sharp':
        0xed78, // [sharp] places — accessibility, aid, assistance, audio, call
    'tune': 0xe683, // image — adjust, adjustments, audio, balance, bars
    'tune_outlined':
        0xf466, // [outline] image — adjust, adjustments, audio, balance, bars
    'tune_rounded':
        0xf0258, // [round] image — adjust, adjustments, audio, balance, bars
    'tune_sharp':
        0xed79, // [sharp] image — adjust, adjustments, audio, balance, bars
    'tungsten':
        0xe684, // device — adjustments, balance, bright, brightness, camera
    'tungsten_outlined':
        0xf467, // [outline] device — adjustments, balance, bright, brightness, camera
    'tungsten_rounded':
        0xf0259, // [round] device — adjustments, balance, bright, brightness, camera
    'tungsten_sharp':
        0xed7a, // [sharp] device — adjustments, balance, bright, brightness, camera
    'turn_left': 0xf058f, // maps — angle, arrow, arrows, bend, curve
    'turn_left_outlined':
        0xf0683, // [outline] maps — angle, arrow, arrows, bend, curve
    'turn_left_rounded':
        0xf03a2, // [round] maps — angle, arrow, arrows, bend, curve
    'turn_left_sharp':
        0xf0495, // [sharp] maps — angle, arrow, arrows, bend, curve
    'turn_right':
        0xf0590, // maps — arrow, arrows, bend right, changing direction, curved arrow
    'turn_right_outlined':
        0xf0684, // [outline] maps — arrow, arrows, bend right, changing direction, curved arrow
    'turn_right_rounded':
        0xf03a3, // [round] maps — arrow, arrows, bend right, changing direction, curved arrow
    'turn_right_sharp':
        0xf0496, // [sharp] maps — arrow, arrows, bend right, changing direction, curved arrow
    'turn_sharp_left': 0xf0591, // maps — angle, arrow, arrows, bend, curve
    'turn_sharp_left_outlined':
        0xf0685, // [outline] maps — angle, arrow, arrows, bend, curve
    'turn_sharp_left_rounded':
        0xf03a4, // [round] maps — angle, arrow, arrows, bend, curve
    'turn_sharp_left_sharp':
        0xf0497, // [sharp] maps — angle, arrow, arrows, bend, curve
    'turn_sharp_right': 0xf0592, // maps — acute turn, arrow, arrows, car, curve
    'turn_sharp_right_outlined':
        0xf0686, // [outline] maps — acute turn, arrow, arrows, car, curve
    'turn_sharp_right_rounded':
        0xf03a5, // [round] maps — acute turn, arrow, arrows, car, curve
    'turn_sharp_right_sharp':
        0xf0498, // [sharp] maps — acute turn, arrow, arrows, car, curve
    'turn_slight_left':
        0xf0593, // maps — angle, arrow, arrows, bend, change direction
    'turn_slight_left_outlined':
        0xf0687, // [outline] maps — angle, arrow, arrows, bend, change direction
    'turn_slight_left_rounded':
        0xf03a6, // [round] maps — angle, arrow, arrows, bend, change direction
    'turn_slight_left_sharp':
        0xf0499, // [sharp] maps — angle, arrow, arrows, bend, change direction
    'turn_slight_right': 0xf0594, // maps — arrow, arrows, bend, curve, detour
    'turn_slight_right_outlined':
        0xf0688, // [outline] maps — arrow, arrows, bend, curve, detour
    'turn_slight_right_rounded':
        0xf03a7, // [round] maps — arrow, arrows, bend, curve, detour
    'turn_slight_right_sharp':
        0xf049a, // [sharp] maps — arrow, arrows, bend, curve, detour
    'turned_in': 0xe685, // action — archive, article, book, bookmark, browser
    'turned_in_not':
        0xe686, // action — archive, article, book, bookmark, browser
    'turned_in_not_outlined':
        0xf468, // [outline] action — archive, article, book, bookmark, browser
    'turned_in_not_rounded':
        0xf025a, // [round] action — archive, article, book, bookmark, browser
    'turned_in_not_sharp':
        0xed7b, // [sharp] action — archive, article, book, bookmark, browser
    'turned_in_outlined':
        0xf469, // [outline] action — archive, article, book, bookmark, browser
    'turned_in_rounded':
        0xf025b, // [round] action — archive, article, book, bookmark, browser
    'turned_in_sharp':
        0xed7c, // [sharp] action — archive, article, book, bookmark, browser
    'tv':
        0xe687, // hardware — device, display, entertainment, entertainment center, glyph
    'tv_off': 0xe688, // notification — Android, OS, block, cancel, chrome
    'tv_off_outlined':
        0xf46a, // [outline] notification — Android, OS, block, cancel, chrome
    'tv_off_rounded':
        0xf025c, // [round] notification — Android, OS, block, cancel, chrome
    'tv_off_sharp':
        0xed7d, // [sharp] notification — Android, OS, block, cancel, chrome
    'tv_outlined':
        0xf46b, // [outline] hardware — device, display, entertainment, entertainment center, glyph
    'tv_rounded':
        0xf025d, // [round] hardware — device, display, entertainment, entertainment center, glyph
    'tv_sharp':
        0xed7e, // [sharp] hardware — device, display, entertainment, entertainment center, glyph
    'twelve_mp': 0xe003, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'twelve_mp_outlined':
        0xedf5, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twelve_mp_rounded':
        0xf4e2, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twelve_mp_sharp':
        0xe703, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twenty_four_mp': 0xe012,
    'twenty_four_mp_outlined': 0xee04,
    'twenty_four_mp_rounded': 0xf4f1,
    'twenty_four_mp_sharp': 0xe712,
    'twenty_mp': 0xe00e, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'twenty_mp_outlined':
        0xee00, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twenty_mp_rounded':
        0xf4ed, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twenty_mp_sharp':
        0xe70e, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'twenty_one_mp': 0xe00f,
    'twenty_one_mp_outlined': 0xee01,
    'twenty_one_mp_rounded': 0xf4ee,
    'twenty_one_mp_sharp': 0xe70f,
    'twenty_three_mp': 0xe011,
    'twenty_three_mp_outlined': 0xee03,
    'twenty_three_mp_rounded': 0xf4f0,
    'twenty_three_mp_sharp': 0xe711,
    'twenty_two_mp': 0xe010,
    'twenty_two_mp_outlined': 0xee02,
    'twenty_two_mp_rounded': 0xf4ef,
    'twenty_two_mp_sharp': 0xe710,
    'two_k': 0xe013, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_outlined':
        0xee05, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_plus': 0xe014, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_plus_outlined':
        0xee06, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_plus_rounded':
        0xf4f2, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_plus_sharp':
        0xe713, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_rounded':
        0xf4f3, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_k_sharp':
        0xe714, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_mp': 0xe015, // resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_mp_outlined':
        0xee07, // [outline] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_mp_rounded':
        0xf4f4, // [round] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_mp_sharp':
        0xe715, // [sharp] resolution / quality label (e.g. 4K, 8MP, 5G)
    'two_wheeler': 0xe689, // maps — automobile, bike, car, cars, commuting
    'two_wheeler_outlined':
        0xf46c, // [outline] maps — automobile, bike, car, cars, commuting
    'two_wheeler_rounded':
        0xf025e, // [round] maps — automobile, bike, car, cars, commuting
    'two_wheeler_sharp':
        0xed7f, // [sharp] maps — automobile, bike, car, cars, commuting
    'type_specimen':
        0xf07d0, // editor — characters, creative, design, detail, display
    'type_specimen_outlined':
        0xf0720, // [outline] editor — characters, creative, design, detail, display
    'type_specimen_rounded':
        0xf0828, // [round] editor — characters, creative, design, detail, display
    'type_specimen_sharp':
        0xf0778, // [sharp] editor — characters, creative, design, detail, display
    'u_turn_left':
        0xf0595, // maps — arrow, arrows, bend, change direction, circle
    'u_turn_left_outlined':
        0xf0689, // [outline] maps — arrow, arrows, bend, change direction, circle
    'u_turn_left_rounded':
        0xf03a8, // [round] maps — arrow, arrows, bend, change direction, circle
    'u_turn_left_sharp':
        0xf049b, // [sharp] maps — arrow, arrows, bend, change direction, circle
    'u_turn_right':
        0xf0596, // maps — arrow, arrows, bend, car, change direction
    'u_turn_right_outlined':
        0xf068a, // [outline] maps — arrow, arrows, bend, car, change direction
    'u_turn_right_rounded':
        0xf03a9, // [round] maps — arrow, arrows, bend, car, change direction
    'u_turn_right_sharp':
        0xf049c, // [sharp] maps — arrow, arrows, bend, car, change direction
    'umbrella':
        0xe68a, // places — accessory, bad weather, beach, clothing, cover
    'umbrella_outlined':
        0xf46d, // [outline] places — accessory, bad weather, beach, clothing, cover
    'umbrella_rounded':
        0xf025f, // [round] places — accessory, bad weather, beach, clothing, cover
    'umbrella_sharp':
        0xed80, // [sharp] places — accessory, bad weather, beach, clothing, cover
    'unarchive': 0xe68b, // content — access, archive, arrow, box, command
    'unarchive_outlined':
        0xf46e, // [outline] content — access, archive, arrow, box, command
    'unarchive_rounded':
        0xf0260, // [round] content — access, archive, arrow, box, command
    'unarchive_sharp':
        0xed81, // [sharp] content — access, archive, arrow, box, command
    'undo': 0xe68c, // content — arrow, back, backward, cancel, change
    'undo_outlined':
        0xf46f, // [outline] content — arrow, back, backward, cancel, change
    'undo_rounded':
        0xf0261, // [round] content — arrow, back, backward, cancel, change
    'undo_sharp':
        0xed82, // [sharp] content — arrow, back, backward, cancel, change
    'unfold_less':
        0xe68d, // navigation — arrow, arrows, chevron, close, collapse
    'unfold_less_double':
        0xf0879, // action — arrow, arrows, arrows down, arrows inward, arrows pointing in
    'unfold_less_double_outlined':
        0xf08b4, // [outline] action — arrow, arrows, arrows down, arrows inward, arrows pointing in
    'unfold_less_double_rounded':
        0xf0896, // [round] action — arrow, arrows, arrows down, arrows inward, arrows pointing in
    'unfold_less_double_sharp':
        0xf084d, // [sharp] action — arrow, arrows, arrows down, arrows inward, arrows pointing in
    'unfold_less_outlined':
        0xf470, // [outline] navigation — arrow, arrows, chevron, close, collapse
    'unfold_less_rounded':
        0xf0262, // [round] navigation — arrow, arrows, chevron, close, collapse
    'unfold_less_sharp':
        0xed83, // [sharp] navigation — arrow, arrows, chevron, close, collapse
    'unfold_more':
        0xe68e, // navigation — arrow, arrows, caret, chevron, collapse
    'unfold_more_double':
        0xf087a, // action — additional, arrow, arrows, chevron, collapse
    'unfold_more_double_outlined':
        0xf08b5, // [outline] action — additional, arrow, arrows, chevron, collapse
    'unfold_more_double_rounded':
        0xf0897, // [round] action — additional, arrow, arrows, chevron, collapse
    'unfold_more_double_sharp':
        0xf084e, // [sharp] action — additional, arrow, arrows, chevron, collapse
    'unfold_more_outlined':
        0xf471, // [outline] navigation — arrow, arrows, caret, chevron, collapse
    'unfold_more_rounded':
        0xf0263, // [round] navigation — arrow, arrows, caret, chevron, collapse
    'unfold_more_sharp':
        0xed84, // [sharp] navigation — arrow, arrows, caret, chevron, collapse
    'unpublished':
        0xe68f, // action — analysis, analytics, approve, bar chart, bar graph
    'unpublished_outlined':
        0xf472, // [outline] action — analysis, analytics, approve, bar chart, bar graph
    'unpublished_rounded':
        0xf0264, // [round] action — analysis, analytics, approve, bar chart, bar graph
    'unpublished_sharp':
        0xed85, // [sharp] action — analysis, analytics, approve, bar chart, bar graph
    'unsubscribe':
        0xe690, // communication — account, cancel, circle, close, communication
    'unsubscribe_outlined':
        0xf473, // [outline] communication — account, cancel, circle, close, communication
    'unsubscribe_rounded':
        0xf0265, // [round] communication — account, cancel, circle, close, communication
    'unsubscribe_sharp':
        0xed86, // [sharp] communication — account, cancel, circle, close, communication
    'upcoming':
        0xe691, // content — agenda, alarm, anticipation, appointment, calendar
    'upcoming_outlined':
        0xf474, // [outline] content — agenda, alarm, anticipation, appointment, calendar
    'upcoming_rounded':
        0xf0266, // [round] content — agenda, alarm, anticipation, appointment, calendar
    'upcoming_sharp':
        0xed87, // [sharp] content — agenda, alarm, anticipation, appointment, calendar
    'update': 0xe692, // action — arrow, arrow circle, back, backwards, circle
    'update_disabled':
        0xe693, // action — arrow, back, backwards, blocked, cancelled
    'update_disabled_outlined':
        0xf475, // [outline] action — arrow, back, backwards, blocked, cancelled
    'update_disabled_rounded':
        0xf0267, // [round] action — arrow, back, backwards, blocked, cancelled
    'update_disabled_sharp':
        0xed88, // [sharp] action — arrow, back, backwards, blocked, cancelled
    'update_outlined':
        0xf476, // [outline] action — arrow, arrow circle, back, backwards, circle
    'update_rounded':
        0xf0268, // [round] action — arrow, arrow circle, back, backwards, circle
    'update_sharp':
        0xed89, // [sharp] action — arrow, arrow circle, back, backwards, circle
    'upgrade': 0xe694, // action — above, advance, arrow, ascent, better
    'upgrade_outlined':
        0xf477, // [outline] action — above, advance, arrow, ascent, better
    'upgrade_rounded':
        0xf0269, // [round] action — above, advance, arrow, ascent, better
    'upgrade_sharp':
        0xed8a, // [sharp] action — above, advance, arrow, ascent, better
    'upload': 0xe695, // file — add, arrow, arrows, attach, backup
    'upload_file': 0xe696, // file — add, arrow, cloud, doc, document
    'upload_file_outlined':
        0xf478, // [outline] file — add, arrow, cloud, doc, document
    'upload_file_rounded':
        0xf026a, // [round] file — add, arrow, cloud, doc, document
    'upload_file_sharp':
        0xed8b, // [sharp] file — add, arrow, cloud, doc, document
    'upload_outlined':
        0xf479, // [outline] file — add, arrow, arrows, attach, backup
    'upload_rounded':
        0xf026b, // [round] file — add, arrow, arrows, attach, backup
    'upload_sharp': 0xed8c, // [sharp] file — add, arrow, arrows, attach, backup
    'usb': 0xe697, // device — accessory, cable, computer, connection, connector
    'usb_off':
        0xe698, // device — block, cable, computing, connection, cross out
    'usb_off_outlined':
        0xf47a, // [outline] device — block, cable, computing, connection, cross out
    'usb_off_rounded':
        0xf026c, // [round] device — block, cable, computing, connection, cross out
    'usb_off_sharp':
        0xed8d, // [sharp] device — block, cable, computing, connection, cross out
    'usb_outlined':
        0xf47b, // [outline] device — accessory, cable, computer, connection, connector
    'usb_rounded':
        0xf026d, // [round] device — accessory, cable, computer, connection, connector
    'usb_sharp':
        0xed8e, // [sharp] device — accessory, cable, computer, connection, connector
    'vaccines': 0xf0597, // social — aid, care, circle, clinic, covid
    'vaccines_outlined':
        0xf068b, // [outline] social — aid, care, circle, clinic, covid
    'vaccines_rounded':
        0xf03aa, // [round] social — aid, care, circle, clinic, covid
    'vaccines_sharp':
        0xf049d, // [sharp] social — aid, care, circle, clinic, covid
    'vape_free':
        0xf06c5, // places — addiction, ban, circle, diagonal line, disabled
    'vape_free_outlined':
        0xf06ab, // [outline] places — addiction, ban, circle, diagonal line, disabled
    'vape_free_rounded':
        0xf06d2, // [round] places — addiction, ban, circle, diagonal line, disabled
    'vape_free_sharp':
        0xf06b8, // [sharp] places — addiction, ban, circle, diagonal line, disabled
    'vaping_rooms':
        0xf06c6, // places — allowance, allowed, amenities, area, building
    'vaping_rooms_outlined':
        0xf06ac, // [outline] places — allowance, allowed, amenities, area, building
    'vaping_rooms_rounded':
        0xf06d3, // [round] places — allowance, allowed, amenities, area, building
    'vaping_rooms_sharp':
        0xf06b9, // [sharp] places — allowance, allowed, amenities, area, building
    'verified':
        0xe699, // action — accepted, accreditation, approval, approve, authentic
    'verified_outlined':
        0xf47c, // [outline] action — accepted, accreditation, approval, approve, authentic
    'verified_rounded':
        0xf026e, // [round] action — accepted, accreditation, approval, approve, authentic
    'verified_sharp':
        0xed8f, // [sharp] action — accepted, accreditation, approval, approve, authentic
    'verified_user':
        0xe69a, // action — approve, badge, certified, check, complete
    'verified_user_outlined':
        0xf47d, // [outline] action — approve, badge, certified, check, complete
    'verified_user_rounded':
        0xf026f, // [round] action — approve, badge, certified, check, complete
    'verified_user_sharp':
        0xed90, // [sharp] action — approve, badge, certified, check, complete
    'vertical_align_bottom':
        0xe69b, // editor — align, alignment, arrange, arrow, bottom
    'vertical_align_bottom_outlined':
        0xf47e, // [outline] editor — align, alignment, arrange, arrow, bottom
    'vertical_align_bottom_rounded':
        0xf0270, // [round] editor — align, alignment, arrange, arrow, bottom
    'vertical_align_bottom_sharp':
        0xed91, // [sharp] editor — align, alignment, arrange, arrow, bottom
    'vertical_align_center':
        0xe69c, // editor — align, alignment, arrange, arrow, bars
    'vertical_align_center_outlined':
        0xf47f, // [outline] editor — align, alignment, arrange, arrow, bars
    'vertical_align_center_rounded':
        0xf0271, // [round] editor — align, alignment, arrange, arrow, bars
    'vertical_align_center_sharp':
        0xed92, // [sharp] editor — align, alignment, arrange, arrow, bars
    'vertical_align_top':
        0xe69d, // editor — align, alignment, arrange, arrow, box
    'vertical_align_top_outlined':
        0xf480, // [outline] editor — align, alignment, arrange, arrow, box
    'vertical_align_top_rounded':
        0xf0272, // [round] editor — align, alignment, arrange, arrow, box
    'vertical_align_top_sharp':
        0xed93, // [sharp] editor — align, alignment, arrange, arrow, box
    'vertical_distribute':
        0xe69e, // editor — align, alignment, bars, design tools, direction
    'vertical_distribute_outlined':
        0xf481, // [outline] editor — align, alignment, bars, design tools, direction
    'vertical_distribute_rounded':
        0xf0273, // [round] editor — align, alignment, bars, design tools, direction
    'vertical_distribute_sharp':
        0xed94, // [sharp] editor — align, alignment, bars, design tools, direction
    'vertical_shades': 0xf07d1, // home — adjust, bars, blinds, building, cover
    'vertical_shades_closed':
        0xf07d2, // home — barrier, blinds, closed, cover, covering
    'vertical_shades_closed_outlined':
        0xf0721, // [outline] home — barrier, blinds, closed, cover, covering
    'vertical_shades_closed_rounded':
        0xf0829, // [round] home — barrier, blinds, closed, cover, covering
    'vertical_shades_closed_sharp':
        0xf0779, // [sharp] home — barrier, blinds, closed, cover, covering
    'vertical_shades_outlined':
        0xf0722, // [outline] home — adjust, bars, blinds, building, cover
    'vertical_shades_rounded':
        0xf082a, // [round] home — adjust, bars, blinds, building, cover
    'vertical_shades_sharp':
        0xf077a, // [sharp] home — adjust, bars, blinds, building, cover
    'vertical_split':
        0xe69f, // action — arrangement, columns, content layout, design, display
    'vertical_split_outlined':
        0xf482, // [outline] action — arrangement, columns, content layout, design, display
    'vertical_split_rounded':
        0xf0274, // [round] action — arrangement, columns, content layout, design, display
    'vertical_split_sharp':
        0xed95, // [sharp] action — arrangement, columns, content layout, design, display
    'vibration': 0xe6a0, // notification — Android, OS, alert, audio, cell
    'vibration_outlined':
        0xf483, // [outline] notification — Android, OS, alert, audio, cell
    'vibration_rounded':
        0xf0275, // [round] notification — Android, OS, alert, audio, cell
    'vibration_sharp':
        0xed96, // [sharp] notification — Android, OS, alert, audio, cell
    'video_call': 0xe6a1, // av — +, add, audio, broadcast, call
    'video_call_outlined':
        0xf484, // [outline] av — +, add, audio, broadcast, call
    'video_call_rounded':
        0xf0276, // [round] av — +, add, audio, broadcast, call
    'video_call_sharp': 0xed97, // [sharp] av — +, add, audio, broadcast, call
    'video_camera_back':
        0xe6a2, // image — back, camera, capture, electronic device, entertainment
    'video_camera_back_outlined':
        0xf485, // [outline] image — back, camera, capture, electronic device, entertainment
    'video_camera_back_rounded':
        0xf0277, // [round] image — back, camera, capture, electronic device, entertainment
    'video_camera_back_sharp':
        0xed98, // [sharp] image — back, camera, capture, electronic device, entertainment
    'video_camera_front':
        0xe6a3, // image — account, broadcast, camera, capture, communication
    'video_camera_front_outlined':
        0xf486, // [outline] image — account, broadcast, camera, capture, communication
    'video_camera_front_rounded':
        0xf0278, // [round] image — account, broadcast, camera, capture, communication
    'video_camera_front_sharp':
        0xed99, // [sharp] image — account, broadcast, camera, capture, communication
    'video_chat': 0xf087b, // notification — avatar, bubble, call, cam, camera
    'video_chat_outlined':
        0xf08b6, // [outline] notification — avatar, bubble, call, cam, camera
    'video_chat_rounded':
        0xf0898, // [round] notification — avatar, bubble, call, cam, camera
    'video_chat_sharp':
        0xf084f, // [sharp] notification — avatar, bubble, call, cam, camera
    'video_collection': 0xe6a5,
    'video_collection_outlined': 0xf488,
    'video_collection_rounded': 0xf027a,
    'video_collection_sharp': 0xed9b,
    'video_file':
        0xf0598, // av — camera, doc, document, document type, extension
    'video_file_outlined':
        0xf068c, // [outline] av — camera, doc, document, document type, extension
    'video_file_rounded':
        0xf03ab, // [round] av — camera, doc, document, document type, extension
    'video_file_sharp':
        0xf049e, // [sharp] av — camera, doc, document, document type, extension
    'video_label':
        0xe6a4, // av — category, cinematic, classification, clip, content
    'video_label_outlined':
        0xf487, // [outline] av — category, cinematic, classification, clip, content
    'video_label_rounded':
        0xf0279, // [round] av — category, cinematic, classification, clip, content
    'video_label_sharp':
        0xed9a, // [sharp] av — category, cinematic, classification, clip, content
    'video_library': 0xe6a5, // av — archive, arrow, category, content, document
    'video_library_outlined':
        0xf488, // [outline] av — archive, arrow, category, content, document
    'video_library_rounded':
        0xf027a, // [round] av — archive, arrow, category, content, document
    'video_library_sharp':
        0xed9b, // [sharp] av — archive, arrow, category, content, document
    'video_settings':
        0xe6a6, // av — adjust, change, cogwheel, configuration, details
    'video_settings_outlined':
        0xf489, // [outline] av — adjust, change, cogwheel, configuration, details
    'video_settings_rounded':
        0xf027b, // [round] av — adjust, change, cogwheel, configuration, details
    'video_settings_sharp':
        0xed9c, // [sharp] av — adjust, change, cogwheel, configuration, details
    'video_stable':
        0xe6a7, // image — abstract, alignment, anti-shake, balance, camera
    'video_stable_outlined':
        0xf48a, // [outline] image — abstract, alignment, anti-shake, balance, camera
    'video_stable_rounded':
        0xf027c, // [round] image — abstract, alignment, anti-shake, balance, camera
    'video_stable_sharp':
        0xed9d, // [sharp] image — abstract, alignment, anti-shake, balance, camera
    'videocam': 0xe6a8, // av — broadcast, broadcasting, cam, camera, capture
    'videocam_off': 0xe6a9, // av — blocked, broadcasting, call, cam, camera
    'videocam_off_outlined':
        0xf48b, // [outline] av — blocked, broadcasting, call, cam, camera
    'videocam_off_rounded':
        0xf027d, // [round] av — blocked, broadcasting, call, cam, camera
    'videocam_off_sharp':
        0xed9e, // [sharp] av — blocked, broadcasting, call, cam, camera
    'videocam_outlined':
        0xf48c, // [outline] av — broadcast, broadcasting, cam, camera, capture
    'videocam_rounded':
        0xf027e, // [round] av — broadcast, broadcasting, cam, camera, capture
    'videocam_sharp':
        0xed9f, // [sharp] av — broadcast, broadcasting, cam, camera, capture
    'videogame_asset':
        0xe6aa, // hardware — asset, console, controller, d-pad, device
    'videogame_asset_off':
        0xe6ab, // hardware — asset, console, controller, cross, delete
    'videogame_asset_off_outlined':
        0xf48d, // [outline] hardware — asset, console, controller, cross, delete
    'videogame_asset_off_rounded':
        0xf027f, // [round] hardware — asset, console, controller, cross, delete
    'videogame_asset_off_sharp':
        0xeda0, // [sharp] hardware — asset, console, controller, cross, delete
    'videogame_asset_outlined':
        0xf48e, // [outline] hardware — asset, console, controller, d-pad, device
    'videogame_asset_rounded':
        0xf0280, // [round] hardware — asset, console, controller, d-pad, device
    'videogame_asset_sharp':
        0xeda1, // [sharp] hardware — asset, console, controller, d-pad, device
    'view_agenda':
        0xe6ac, // action — agenda, agenda view, arrange, blocks, calendar
    'view_agenda_outlined':
        0xf48f, // [outline] action — agenda, agenda view, arrange, blocks, calendar
    'view_agenda_rounded':
        0xf0281, // [round] action — agenda, agenda view, arrange, blocks, calendar
    'view_agenda_sharp':
        0xeda2, // [sharp] action — agenda, agenda view, arrange, blocks, calendar
    'view_array':
        0xe6ad, // action — arrange, arrangement, array, blocks, columns
    'view_array_outlined':
        0xf490, // [outline] action — arrange, arrangement, array, blocks, columns
    'view_array_rounded':
        0xf0282, // [round] action — arrange, arrangement, array, blocks, columns
    'view_array_sharp':
        0xeda3, // [sharp] action — arrange, arrangement, array, blocks, columns
    'view_carousel':
        0xe6ae, // action — cards, carousel, content, design, display
    'view_carousel_outlined':
        0xf491, // [outline] action — cards, carousel, content, design, display
    'view_carousel_rounded':
        0xf0283, // [round] action — cards, carousel, content, design, display
    'view_carousel_sharp':
        0xeda4, // [sharp] action — cards, carousel, content, design, display
    'view_column':
        0xe6af, // action — alignment, arrangement, column, columns, data display
    'view_column_outlined':
        0xf492, // [outline] action — alignment, arrangement, column, columns, data display
    'view_column_rounded':
        0xf0284, // [round] action — alignment, arrangement, column, columns, data display
    'view_column_sharp':
        0xeda5, // [sharp] action — alignment, arrangement, column, columns, data display
    'view_comfortable': 0xe6b0,
    'view_comfortable_outlined': 0xf493,
    'view_comfortable_rounded': 0xf0285,
    'view_comfortable_sharp': 0xeda6,
    'view_comfy': 0xe6b0, // image — arrange, blocks, boxes, cells, comfy
    'view_comfy_alt': 0xf0599, // action — alt, area, arrangement, blocks, boxes
    'view_comfy_alt_outlined':
        0xf068d, // [outline] action — alt, area, arrangement, blocks, boxes
    'view_comfy_alt_rounded':
        0xf03ac, // [round] action — alt, area, arrangement, blocks, boxes
    'view_comfy_alt_sharp':
        0xf049f, // [sharp] action — alt, area, arrangement, blocks, boxes
    'view_comfy_outlined':
        0xf493, // [outline] image — arrange, blocks, boxes, cells, comfy
    'view_comfy_rounded':
        0xf0285, // [round] image — arrange, blocks, boxes, cells, comfy
    'view_comfy_sharp':
        0xeda6, // [sharp] image — arrange, blocks, boxes, cells, comfy
    'view_compact': 0xe6b1, // image — alignment, arrange, array, blocks, boxes
    'view_compact_alt':
        0xf059a, // action — alt, alternate, arrange, blocks, box
    'view_compact_alt_outlined':
        0xf068e, // [outline] action — alt, alternate, arrange, blocks, box
    'view_compact_alt_rounded':
        0xf03ad, // [round] action — alt, alternate, arrange, blocks, box
    'view_compact_alt_sharp':
        0xf04a0, // [sharp] action — alt, alternate, arrange, blocks, box
    'view_compact_outlined':
        0xf494, // [outline] image — alignment, arrange, array, blocks, boxes
    'view_compact_rounded':
        0xf0286, // [round] image — alignment, arrange, array, blocks, boxes
    'view_compact_sharp':
        0xeda7, // [sharp] image — alignment, arrange, array, blocks, boxes
    'view_cozy':
        0xf059b, // action — arrangement, boxes, close, clustered, comfy
    'view_cozy_outlined':
        0xf068f, // [outline] action — arrangement, boxes, close, clustered, comfy
    'view_cozy_rounded':
        0xf03ae, // [round] action — arrangement, boxes, close, clustered, comfy
    'view_cozy_sharp':
        0xf04a1, // [sharp] action — arrangement, boxes, close, clustered, comfy
    'view_day':
        0xe6b2, // action — appointment, arrangement, bar, blocks, calendar
    'view_day_outlined':
        0xf495, // [outline] action — appointment, arrangement, bar, blocks, calendar
    'view_day_rounded':
        0xf0287, // [round] action — appointment, arrangement, bar, blocks, calendar
    'view_day_sharp':
        0xeda8, // [sharp] action — appointment, arrangement, bar, blocks, calendar
    'view_headline': 0xe6b3, // action — area, arrangement, article, bars, block
    'view_headline_outlined':
        0xf496, // [outline] action — area, arrangement, article, bars, block
    'view_headline_rounded':
        0xf0288, // [round] action — area, arrangement, article, bars, block
    'view_headline_sharp':
        0xeda9, // [sharp] action — area, arrangement, article, bars, block
    'view_in_ar': 0xe6b4, // action — 3d, 3d model, ar, ar experience, augmented
    'view_in_ar_outlined':
        0xf497, // [outline] action — 3d, 3d model, ar, ar experience, augmented
    'view_in_ar_rounded':
        0xf0289, // [round] action — 3d, 3d model, ar, ar experience, augmented
    'view_in_ar_sharp':
        0xedaa, // [sharp] action — 3d, 3d model, ar, ar experience, augmented
    'view_kanban': 0xf059c, // action — agile, blocks, board, cards, column
    'view_kanban_outlined':
        0xf0690, // [outline] action — agile, blocks, board, cards, column
    'view_kanban_rounded':
        0xf03af, // [round] action — agile, blocks, board, cards, column
    'view_kanban_sharp':
        0xf04a2, // [sharp] action — agile, blocks, board, cards, column
    'view_list':
        0xe6b5, // action — arrangement, bulleted, catalog, compact, content
    'view_list_outlined':
        0xf498, // [outline] action — arrangement, bulleted, catalog, compact, content
    'view_list_rounded':
        0xf028a, // [round] action — arrangement, bulleted, catalog, compact, content
    'view_list_sharp':
        0xedab, // [sharp] action — arrangement, bulleted, catalog, compact, content
    'view_module':
        0xe6b6, // action — arrange, arrangement, blocks, content, dashboard
    'view_module_outlined':
        0xf499, // [outline] action — arrange, arrangement, blocks, content, dashboard
    'view_module_rounded':
        0xf028b, // [round] action — arrange, arrangement, blocks, content, dashboard
    'view_module_sharp':
        0xedac, // [sharp] action — arrange, arrangement, blocks, content, dashboard
    'view_quilt':
        0xe6b7, // action — arrangement, blocks, columns, composition, dashboard
    'view_quilt_outlined':
        0xf49a, // [outline] action — arrangement, blocks, columns, composition, dashboard
    'view_quilt_rounded':
        0xf028c, // [round] action — arrangement, blocks, columns, composition, dashboard
    'view_quilt_sharp':
        0xedad, // [sharp] action — arrangement, blocks, columns, composition, dashboard
    'view_sidebar': 0xe6b8, // action — area, bar, collapse, column, content
    'view_sidebar_outlined':
        0xf49b, // [outline] action — area, bar, collapse, column, content
    'view_sidebar_rounded':
        0xf028d, // [round] action — area, bar, collapse, column, content
    'view_sidebar_sharp':
        0xedae, // [sharp] action — area, bar, collapse, column, content
    'view_stream':
        0xe6b9, // action — arrangement, block view, blocks, columns, content
    'view_stream_outlined':
        0xf49c, // [outline] action — arrangement, block view, blocks, columns, content
    'view_stream_rounded':
        0xf028e, // [round] action — arrangement, block view, blocks, columns, content
    'view_stream_sharp':
        0xedaf, // [sharp] action — arrangement, block view, blocks, columns, content
    'view_timeline':
        0xf059d, // action — analytics, chart, chronological, diagram, display
    'view_timeline_outlined':
        0xf0691, // [outline] action — analytics, chart, chronological, diagram, display
    'view_timeline_rounded':
        0xf03b0, // [round] action — analytics, chart, chronological, diagram, display
    'view_timeline_sharp':
        0xf04a3, // [sharp] action — analytics, chart, chronological, diagram, display
    'view_week':
        0xe6ba, // action — agenda, agenda view, appointment, appointments, bars
    'view_week_outlined':
        0xf49d, // [outline] action — agenda, agenda view, appointment, appointments, bars
    'view_week_rounded':
        0xf028f, // [round] action — agenda, agenda view, appointment, appointments, bars
    'view_week_sharp':
        0xedb0, // [sharp] action — agenda, agenda view, appointment, appointments, bars
    'vignette': 0xe6bb, // image — adjustment, camera, circle, corner, dark
    'vignette_outlined':
        0xf49e, // [outline] image — adjustment, camera, circle, corner, dark
    'vignette_rounded':
        0xf0290, // [round] image — adjustment, camera, circle, corner, dark
    'vignette_sharp':
        0xedb1, // [sharp] image — adjustment, camera, circle, corner, dark
    'villa':
        0xe6bc, // places — accommodation, architecture, beach, building, city
    'villa_outlined':
        0xf49f, // [outline] places — accommodation, architecture, beach, building, city
    'villa_rounded':
        0xf0291, // [round] places — accommodation, architecture, beach, building, city
    'villa_sharp':
        0xedb2, // [sharp] places — accommodation, architecture, beach, building, city
    'visibility': 0xe6bd, // action — display, eye, glance, hidden, hidden text
    'visibility_off':
        0xe6be, // action — conceal, crossed out eye, diagonal line, disabled, disabled view
    'visibility_off_outlined':
        0xf4a0, // [outline] action — conceal, crossed out eye, diagonal line, disabled, disabled view
    'visibility_off_rounded':
        0xf0292, // [round] action — conceal, crossed out eye, diagonal line, disabled, disabled view
    'visibility_off_sharp':
        0xedb3, // [sharp] action — conceal, crossed out eye, diagonal line, disabled, disabled view
    'visibility_outlined':
        0xf4a1, // [outline] action — display, eye, glance, hidden, hidden text
    'visibility_rounded':
        0xf0293, // [round] action — display, eye, glance, hidden, hidden text
    'visibility_sharp':
        0xedb4, // [sharp] action — display, eye, glance, hidden, hidden text
    'voice_chat':
        0xe6bf, // notification — audio, audio call, audio chat, bubble, cam
    'voice_chat_outlined':
        0xf4a2, // [outline] notification — audio, audio call, audio chat, bubble, cam
    'voice_chat_rounded':
        0xf0294, // [round] notification — audio, audio call, audio chat, bubble, cam
    'voice_chat_sharp':
        0xedb5, // [sharp] notification — audio, audio call, audio chat, bubble, cam
    'voice_over_off':
        0xe6c0, // action — accessibility, accessibility feature, accessibility off, account, assistance disabled
    'voice_over_off_outlined':
        0xf4a3, // [outline] action — accessibility, accessibility feature, accessibility off, account, assistance disabled
    'voice_over_off_rounded':
        0xf0295, // [round] action — accessibility, accessibility feature, accessibility off, account, assistance disabled
    'voice_over_off_sharp':
        0xedb6, // [sharp] action — accessibility, accessibility feature, accessibility off, account, assistance disabled
    'voicemail':
        0xe6c1, // communication — alert, audio, audio message, call, circle
    'voicemail_outlined':
        0xf4a4, // [outline] communication — alert, audio, audio message, call, circle
    'voicemail_rounded':
        0xf0296, // [round] communication — alert, audio, audio message, call, circle
    'voicemail_sharp':
        0xedb7, // [sharp] communication — alert, audio, audio message, call, circle
    'volcano': 0xf07d3, // social — alert, ash, cone, crisis, danger
    'volcano_outlined':
        0xf0723, // [outline] social — alert, ash, cone, crisis, danger
    'volcano_rounded':
        0xf082b, // [round] social — alert, ash, cone, crisis, danger
    'volcano_sharp':
        0xf077b, // [sharp] social — alert, ash, cone, crisis, danger
    'volume_down':
        0xe6c2, // av — acoustic, audio, audio adjustment, audio control, audio level
    'volume_down_alt': 0xf059e, // av — adjustment, alt, amplifier, arc, audio
    'volume_down_outlined':
        0xf4a5, // [outline] av — acoustic, audio, audio adjustment, audio control, audio level
    'volume_down_rounded':
        0xf0297, // [round] av — acoustic, audio, audio adjustment, audio control, audio level
    'volume_down_sharp':
        0xedb8, // [sharp] av — acoustic, audio, audio adjustment, audio control, audio level
    'volume_mute':
        0xe6c3, // av — audio, audio off, cancel, diagonal line, disabled
    'volume_mute_outlined':
        0xf4a6, // [outline] av — audio, audio off, cancel, diagonal line, disabled
    'volume_mute_rounded':
        0xf0298, // [round] av — audio, audio off, cancel, diagonal line, disabled
    'volume_mute_sharp':
        0xedb9, // [sharp] av — audio, audio off, cancel, diagonal line, disabled
    'volume_off':
        0xe6c4, // av — accessibility, audio, audio control, audio off, cross out
    'volume_off_outlined':
        0xf4a7, // [outline] av — accessibility, audio, audio control, audio off, cross out
    'volume_off_rounded':
        0xf0299, // [round] av — accessibility, audio, audio control, audio off, cross out
    'volume_off_sharp':
        0xedba, // [sharp] av — accessibility, audio, audio control, audio off, cross out
    'volume_up':
        0xe6c5, // av — acoustic, adjust volume, amplify, audio, audio bars
    'volume_up_outlined':
        0xf4a8, // [outline] av — acoustic, adjust volume, amplify, audio, audio bars
    'volume_up_rounded':
        0xf029a, // [round] av — acoustic, adjust volume, amplify, audio, audio bars
    'volume_up_sharp':
        0xedbb, // [sharp] av — acoustic, adjust volume, amplify, audio, audio bars
    'volunteer_activism':
        0xe6c6, // maps — activism, aid, assistance, care, cause
    'volunteer_activism_outlined':
        0xf4a9, // [outline] maps — activism, aid, assistance, care, cause
    'volunteer_activism_rounded':
        0xf029b, // [round] maps — activism, aid, assistance, care, cause
    'volunteer_activism_sharp':
        0xedbc, // [sharp] maps — activism, aid, assistance, care, cause
    'vpn_key':
        0xe6c7, // communication — access, authenticate, authentication, authorization, authorize
    'vpn_key_off':
        0xf059f, // communication — access, account, authentication, blocked, closed
    'vpn_key_off_outlined':
        0xf0692, // [outline] communication — access, account, authentication, blocked, closed
    'vpn_key_off_rounded':
        0xf03b1, // [round] communication — access, account, authentication, blocked, closed
    'vpn_key_off_sharp':
        0xf04a4, // [sharp] communication — access, account, authentication, blocked, closed
    'vpn_key_outlined':
        0xf4aa, // [outline] communication — access, authenticate, authentication, authorization, authorize
    'vpn_key_rounded':
        0xf029c, // [round] communication — access, authenticate, authentication, authorization, authorize
    'vpn_key_sharp':
        0xedbd, // [sharp] communication — access, authenticate, authentication, authorization, authorize
    'vpn_lock':
        0xe6c8, // notification — access, connection, cyber security, data protection, digital security
    'vpn_lock_outlined':
        0xf4ab, // [outline] notification — access, connection, cyber security, data protection, digital security
    'vpn_lock_rounded':
        0xf029d, // [round] notification — access, connection, cyber security, data protection, digital security
    'vpn_lock_sharp':
        0xedbe, // [sharp] notification — access, connection, cyber security, data protection, digital security
    'vrpano': 0xe6c9, // image — 360, angle, camera, circle, digital
    'vrpano_outlined':
        0xf4ac, // [outline] image — 360, angle, camera, circle, digital
    'vrpano_rounded':
        0xf029e, // [round] image — 360, angle, camera, circle, digital
    'vrpano_sharp':
        0xedbf, // [sharp] image — 360, angle, camera, circle, digital
    'wallet': 0xf07d4, // social — account, banking, budget, business, cash
    'wallet_giftcard': 0xe13e,
    'wallet_giftcard_outlined': 0xef2d,
    'wallet_giftcard_rounded': 0xf61a,
    'wallet_giftcard_sharp': 0xe83b,
    'wallet_membership': 0xe13f,
    'wallet_membership_outlined': 0xef2e,
    'wallet_membership_rounded': 0xf61b,
    'wallet_membership_sharp': 0xe83c,
    'wallet_outlined':
        0xf0724, // [outline] social — account, banking, budget, business, cash
    'wallet_rounded':
        0xf082c, // [round] social — account, banking, budget, business, cash
    'wallet_sharp':
        0xf077c, // [sharp] social — account, banking, budget, business, cash
    'wallet_travel': 0xe140,
    'wallet_travel_outlined': 0xef2f,
    'wallet_travel_rounded': 0xf61c,
    'wallet_travel_sharp': 0xe83d,
    'wallpaper':
        0xe6ca, // device — abstract, background, clouds, customize, dash
    'wallpaper_outlined':
        0xf4ad, // [outline] device — abstract, background, clouds, customize, dash
    'wallpaper_rounded':
        0xf029f, // [round] device — abstract, background, clouds, customize, dash
    'wallpaper_sharp':
        0xedc0, // [sharp] device — abstract, background, clouds, customize, dash
    'warehouse':
        0xf05a0, // maps — architecture, building, business, cargo, commercial
    'warehouse_outlined':
        0xf0693, // [outline] maps — architecture, building, business, cargo, commercial
    'warehouse_rounded':
        0xf03b2, // [round] maps — architecture, building, business, cargo, commercial
    'warehouse_sharp':
        0xf04a5, // [sharp] maps — architecture, building, business, cargo, commercial
    'warning': 0xe6cb, // alert — !, alert, attention, caution, danger
    'warning_amber': 0xe6cc, // alert — !, alert, amber, attention, caution
    'warning_amber_outlined':
        0xf4ae, // [outline] alert — !, alert, amber, attention, caution
    'warning_amber_rounded':
        0xf02a0, // [round] alert — !, alert, amber, attention, caution
    'warning_amber_sharp':
        0xedc1, // [sharp] alert — !, alert, amber, attention, caution
    'warning_outlined':
        0xf4af, // [outline] alert — !, alert, attention, caution, danger
    'warning_rounded':
        0xf02a1, // [round] alert — !, alert, attention, caution, danger
    'warning_sharp':
        0xedc2, // [sharp] alert — !, alert, attention, caution, danger
    'wash': 0xe6cd, // places — appliance, bathroom, care, chores, clean
    'wash_outlined':
        0xf4b0, // [outline] places — appliance, bathroom, care, chores, clean
    'wash_rounded':
        0xf02a2, // [round] places — appliance, bathroom, care, chores, clean
    'wash_sharp':
        0xedc3, // [sharp] places — appliance, bathroom, care, chores, clean
    'watch': 0xe6ce, // hardware — accessory, alert, analog, band, circle
    'watch_later':
        0xe6cf, // action — alarm, appointment, calendar, chronometer, clock
    'watch_later_outlined':
        0xf4b1, // [outline] action — alarm, appointment, calendar, chronometer, clock
    'watch_later_rounded':
        0xf02a3, // [round] action — alarm, appointment, calendar, chronometer, clock
    'watch_later_sharp':
        0xedc4, // [sharp] action — alarm, appointment, calendar, chronometer, clock
    'watch_off': 0xf05a1, // hardware — alarm, alert, band, block, cancel
    'watch_off_outlined':
        0xf0694, // [outline] hardware — alarm, alert, band, block, cancel
    'watch_off_rounded':
        0xf03b3, // [round] hardware — alarm, alert, band, block, cancel
    'watch_off_sharp':
        0xf04a6, // [sharp] hardware — alarm, alert, band, block, cancel
    'watch_outlined':
        0xf4b2, // [outline] hardware — accessory, alert, analog, band, circle
    'watch_rounded':
        0xf02a4, // [round] hardware — accessory, alert, analog, band, circle
    'watch_sharp':
        0xedc5, // [sharp] hardware — accessory, alert, analog, band, circle
    'water': 0xe6d0, // device — abstract, aqua, beach, clean, drip
    'water_damage':
        0xe6d1, // places — alert, architecture, building, caution, ceiling
    'water_damage_outlined':
        0xf4b3, // [outline] places — alert, architecture, building, caution, ceiling
    'water_damage_rounded':
        0xf02a5, // [round] places — alert, architecture, building, caution, ceiling
    'water_damage_sharp':
        0xedc6, // [sharp] places — alert, architecture, building, caution, ceiling
    'water_drop':
        0xf05a2, // social — adjustments, aqua, blob, concentration, conservation
    'water_drop_outlined':
        0xf0695, // [outline] social — adjustments, aqua, blob, concentration, conservation
    'water_drop_rounded':
        0xf03b4, // [round] social — adjustments, aqua, blob, concentration, conservation
    'water_drop_sharp':
        0xf04a7, // [sharp] social — adjustments, aqua, blob, concentration, conservation
    'water_outlined':
        0xf4b4, // [outline] device — abstract, aqua, beach, clean, drip
    'water_rounded':
        0xf02a6, // [round] device — abstract, aqua, beach, clean, drip
    'water_sharp':
        0xedc7, // [sharp] device — abstract, aqua, beach, clean, drip
    'waterfall_chart':
        0xe6d2, // navigation — analysis, analytics, bar, bars, breakdown
    'waterfall_chart_outlined':
        0xf4b5, // [outline] navigation — analysis, analytics, bar, bars, breakdown
    'waterfall_chart_rounded':
        0xf02a7, // [round] navigation — analysis, analytics, bar, bars, breakdown
    'waterfall_chart_sharp':
        0xedc8, // [sharp] navigation — analysis, analytics, bar, bars, breakdown
    'waves':
        0xe6d3, // content — audio, audio bars, audio control, audio level, audio signal
    'waves_outlined':
        0xf4b6, // [outline] content — audio, audio bars, audio control, audio level, audio signal
    'waves_rounded':
        0xf02a8, // [round] content — audio, audio bars, audio control, audio level, audio signal
    'waves_sharp':
        0xedc9, // [sharp] content — audio, audio bars, audio control, audio level, audio signal
    'waving_hand':
        0xf05a3, // social — acknowledgement, activity, availability, avatar, body part
    'waving_hand_outlined':
        0xf0696, // [outline] social — acknowledgement, activity, availability, avatar, body part
    'waving_hand_rounded':
        0xf03b5, // [round] social — acknowledgement, activity, availability, avatar, body part
    'waving_hand_sharp':
        0xf04a8, // [sharp] social — acknowledgement, activity, availability, avatar, body part
    'wb_auto': 0xe6d4, // image — A, W, adjust, alphabet, ambient light
    'wb_auto_outlined':
        0xf4b7, // [outline] image — A, W, adjust, alphabet, ambient light
    'wb_auto_rounded':
        0xf02a9, // [round] image — A, W, adjust, alphabet, ambient light
    'wb_auto_sharp':
        0xedca, // [sharp] image — A, W, adjust, alphabet, ambient light
    'wb_cloudy': 0xe6d5, // image — air, atmosphere, balance, climate, cloud
    'wb_cloudy_outlined':
        0xf4b8, // [outline] image — air, atmosphere, balance, climate, cloud
    'wb_cloudy_rounded':
        0xf02aa, // [round] image — air, atmosphere, balance, climate, cloud
    'wb_cloudy_sharp':
        0xedcb, // [sharp] image — air, atmosphere, balance, climate, cloud
    'wb_incandescent': 0xe6d6, // image — balance, base, bright, bulb, edit
    'wb_incandescent_outlined':
        0xf4b9, // [outline] image — balance, base, bright, bulb, edit
    'wb_incandescent_rounded':
        0xf02ab, // [round] image — balance, base, bright, bulb, edit
    'wb_incandescent_sharp':
        0xedcc, // [sharp] image — balance, base, bright, bulb, edit
    'wb_iridescent':
        0xe6d7, // image — adjustments, balance, bright, brightness, camera
    'wb_iridescent_outlined':
        0xf4ba, // [outline] image — adjustments, balance, bright, brightness, camera
    'wb_iridescent_rounded':
        0xf02ac, // [round] image — adjustments, balance, bright, brightness, camera
    'wb_iridescent_sharp':
        0xedcd, // [sharp] image — adjustments, balance, bright, brightness, camera
    'wb_shade': 0xe6d8, // image — adjust, area, balance, blind, building
    'wb_shade_outlined':
        0xf4bb, // [outline] image — adjust, area, balance, blind, building
    'wb_shade_rounded':
        0xf02ad, // [round] image — adjust, area, balance, blind, building
    'wb_shade_sharp':
        0xedce, // [sharp] image — adjust, area, balance, blind, building
    'wb_sunny': 0xe6d9, // image — balance, beams, bright, celestial, circle
    'wb_sunny_outlined':
        0xf4bc, // [outline] image — balance, beams, bright, celestial, circle
    'wb_sunny_rounded':
        0xf02ae, // [round] image — balance, beams, bright, celestial, circle
    'wb_sunny_sharp':
        0xedcf, // [sharp] image — balance, beams, bright, celestial, circle
    'wb_twighlight': 0xe6da, // image — balance, light, lighting, noon, sun
    'wb_twilight':
        0xe6db, // image — ambient, ambient light, astronomy, atmosphere, balance
    'wb_twilight_outlined':
        0xf4bd, // [outline] image — ambient, ambient light, astronomy, atmosphere, balance
    'wb_twilight_rounded':
        0xf02af, // [round] image — ambient, ambient light, astronomy, atmosphere, balance
    'wb_twilight_sharp':
        0xedd0, // [sharp] image — ambient, ambient light, astronomy, atmosphere, balance
    'wc':
        0xe6dc, // notification — accessibility, amenities, bathroom, closet, destination
    'wc_outlined':
        0xf4be, // [outline] notification — accessibility, amenities, bathroom, closet, destination
    'wc_rounded':
        0xf02b0, // [round] notification — accessibility, amenities, bathroom, closet, destination
    'wc_sharp':
        0xedd1, // [sharp] notification — accessibility, amenities, bathroom, closet, destination
    'web': 0xe6dd, // av — advertising, banner, blocks, browser, campaign
    'web_asset':
        0xe6de, // av — application desktop, asset, box, browser, browser window
    'web_asset_off': 0xe6df, // av — alert, asset, blocked, browser, computer
    'web_asset_off_outlined':
        0xf4bf, // [outline] av — alert, asset, blocked, browser, computer
    'web_asset_off_rounded':
        0xf02b1, // [round] av — alert, asset, blocked, browser, computer
    'web_asset_off_sharp':
        0xedd2, // [sharp] av — alert, asset, blocked, browser, computer
    'web_asset_outlined':
        0xf4c0, // [outline] av — application desktop, asset, box, browser, browser window
    'web_asset_rounded':
        0xf02b2, // [round] av — application desktop, asset, box, browser, browser window
    'web_asset_sharp':
        0xedd3, // [sharp] av — application desktop, asset, box, browser, browser window
    'web_outlined':
        0xf4c1, // [outline] av — advertising, banner, blocks, browser, campaign
    'web_rounded':
        0xf02b3, // [round] av — advertising, banner, blocks, browser, campaign
    'web_sharp':
        0xedd4, // [sharp] av — advertising, banner, blocks, browser, campaign
    'web_stories':
        0xe6e0, // content — column, communication, content, divide, feed
    'web_stories_outlined':
        0xf08b7, // [outline] content — column, communication, content, divide, feed
    'web_stories_rounded':
        0xf0899, // [round] content — column, communication, content, divide, feed
    'web_stories_sharp':
        0xf0850, // [sharp] content — column, communication, content, divide, feed
    'webhook': 0xf05a4, // action — alert, api, arrow, automation, backend
    'webhook_outlined':
        0xf0697, // [outline] action — alert, api, arrow, automation, backend
    'webhook_rounded':
        0xf03b6, // [round] action — alert, api, arrow, automation, backend
    'webhook_sharp':
        0xf04a9, // [sharp] action — alert, api, arrow, automation, backend
    'wechat': 0xf05a5,
    'wechat_outlined': 0xf0698,
    'wechat_rounded': 0xf03b7,
    'wechat_sharp': 0xf04aa,
    'weekend':
        0xe6e1, // content — bag, baggage, baggage claim, briefcase, buckle
    'weekend_outlined':
        0xf4c2, // [outline] content — bag, baggage, baggage claim, briefcase, buckle
    'weekend_rounded':
        0xf02b4, // [round] content — bag, baggage, baggage claim, briefcase, buckle
    'weekend_sharp':
        0xedd5, // [sharp] content — bag, baggage, baggage claim, briefcase, buckle
    'west': 0xe6e2, // navigation — arrow, away, back, chevron, direction
    'west_outlined':
        0xf4c3, // [outline] navigation — arrow, away, back, chevron, direction
    'west_rounded':
        0xf02b5, // [round] navigation — arrow, away, back, chevron, direction
    'west_sharp':
        0xedd6, // [sharp] navigation — arrow, away, back, chevron, direction
    'whatshot': 0xe6e3, // social — alert, alerts, arrow, blaze, burning
    'whatshot_outlined':
        0xf4c4, // [outline] social — alert, alerts, arrow, blaze, burning
    'whatshot_rounded':
        0xf02b6, // [round] social — alert, alerts, arrow, blaze, burning
    'whatshot_sharp':
        0xedd7, // [sharp] social — alert, alerts, arrow, blaze, burning
    'wheelchair_pickup':
        0xe6e4, // places — accessibility, accessible, assistance, auto, body
    'wheelchair_pickup_outlined':
        0xf4c5, // [outline] places — accessibility, accessible, assistance, auto, body
    'wheelchair_pickup_rounded':
        0xf02b7, // [round] places — accessibility, accessible, assistance, auto, body
    'wheelchair_pickup_sharp':
        0xedd8, // [sharp] places — accessibility, accessible, assistance, auto, body
    'where_to_vote':
        0xe6e5, // content — address, approve, ballot, campaign, candidate
    'where_to_vote_outlined':
        0xf4c6, // [outline] content — address, approve, ballot, campaign, candidate
    'where_to_vote_rounded':
        0xf02b8, // [round] content — address, approve, ballot, campaign, candidate
    'where_to_vote_sharp':
        0xedd9, // [sharp] content — address, approve, ballot, campaign, candidate
    'widgets': 0xe6e6, // device — add, arrange, blocks, box, boxes
    'widgets_outlined':
        0xf4c7, // [outline] device — add, arrange, blocks, box, boxes
    'widgets_rounded':
        0xf02b9, // [round] device — add, arrange, blocks, box, boxes
    'widgets_sharp':
        0xedda, // [sharp] device — add, arrange, blocks, box, boxes
    'width_full': 0xf07d5, // action — arrows, columns, content, display, expand
    'width_full_outlined':
        0xf0725, // [outline] action — arrows, columns, content, display, expand
    'width_full_rounded':
        0xf082d, // [round] action — arrows, columns, content, display, expand
    'width_full_sharp':
        0xf077d, // [sharp] action — arrows, columns, content, display, expand
    'width_normal':
        0xf07d6, // action — adjust size, adjust width, alignment, boundaries, canvas size
    'width_normal_outlined':
        0xf0726, // [outline] action — adjust size, adjust width, alignment, boundaries, canvas size
    'width_normal_rounded':
        0xf082e, // [round] action — adjust size, adjust width, alignment, boundaries, canvas size
    'width_normal_sharp':
        0xf077e, // [sharp] action — adjust size, adjust width, alignment, boundaries, canvas size
    'width_wide':
        0xf07d7, // action — adjust, aspect ratio, bar, cinema, dimension
    'width_wide_outlined':
        0xf0727, // [outline] action — adjust, aspect ratio, bar, cinema, dimension
    'width_wide_rounded':
        0xf082f, // [round] action — adjust, aspect ratio, bar, cinema, dimension
    'width_wide_sharp':
        0xf077f, // [sharp] action — adjust, aspect ratio, bar, cinema, dimension
    'wifi':
        0xe6e7, // notification — access point, antenna, bars, broadcast, communication
    'wifi_1_bar': 0xf07d8, // device — 1, 1 bar, arc, bar, bars
    'wifi_1_bar_outlined':
        0xf0728, // [outline] device — 1, 1 bar, arc, bar, bars
    'wifi_1_bar_rounded': 0xf0830, // [round] device — 1, 1 bar, arc, bar, bars
    'wifi_1_bar_sharp': 0xf0780, // [sharp] device — 1, 1 bar, arc, bar, bars
    'wifi_2_bar': 0xf07d9, // device — 2, access, bar, bars, bars indicator
    'wifi_2_bar_outlined':
        0xf0729, // [outline] device — 2, access, bar, bars, bars indicator
    'wifi_2_bar_rounded':
        0xf0831, // [round] device — 2, access, bar, bars, bars indicator
    'wifi_2_bar_sharp':
        0xf0781, // [sharp] device — 2, access, bar, bars, bars indicator
    'wifi_calling':
        0xe6e8, // communication — arcs, broadcast, call, calling, cell
    'wifi_calling_3': 0xe6e9, // device — 3, audio, calling, cell, cellular
    'wifi_calling_3_outlined':
        0xf4c8, // [outline] device — 3, audio, calling, cell, cellular
    'wifi_calling_3_rounded':
        0xf02ba, // [round] device — 3, audio, calling, cell, cellular
    'wifi_calling_3_sharp':
        0xeddb, // [sharp] device — 3, audio, calling, cell, cellular
    'wifi_calling_outlined':
        0xf4c9, // [outline] communication — arcs, broadcast, call, calling, cell
    'wifi_calling_rounded':
        0xf02bb, // [round] communication — arcs, broadcast, call, calling, cell
    'wifi_calling_sharp':
        0xeddc, // [sharp] communication — arcs, broadcast, call, calling, cell
    'wifi_channel': 0xf05a7, // device — adjust, arc, arcs, broadcast, cellular
    'wifi_channel_outlined':
        0xf069a, // [outline] device — adjust, arc, arcs, broadcast, cellular
    'wifi_channel_rounded':
        0xf03b9, // [round] device — adjust, arc, arcs, broadcast, cellular
    'wifi_channel_sharp':
        0xf04ac, // [sharp] device — adjust, arc, arcs, broadcast, cellular
    'wifi_find': 0xf05a8, // device — access point, antenna, arc, arch, bars
    'wifi_find_outlined':
        0xf069b, // [outline] device — access point, antenna, arc, arch, bars
    'wifi_find_rounded':
        0xf03ba, // [round] device — access point, antenna, arc, arch, bars
    'wifi_find_sharp':
        0xf04ad, // [sharp] device — access point, antenna, arc, arch, bars
    'wifi_lock':
        0xe6ea, // device — access, authentication, bars, cellular, connect
    'wifi_lock_outlined':
        0xf4ca, // [outline] device — access, authentication, bars, cellular, connect
    'wifi_lock_rounded':
        0xf02bc, // [round] device — access, authentication, bars, cellular, connect
    'wifi_lock_sharp':
        0xeddd, // [sharp] device — access, authentication, bars, cellular, connect
    'wifi_off':
        0xe6eb, // notification — connection, connection off, diagonal line, disabled, disconnected
    'wifi_off_outlined':
        0xf4cb, // [outline] notification — connection, connection off, diagonal line, disabled, disconnected
    'wifi_off_rounded':
        0xf02bd, // [round] notification — connection, connection off, diagonal line, disabled, disconnected
    'wifi_off_sharp':
        0xedde, // [sharp] notification — connection, connection off, diagonal line, disabled, disconnected
    'wifi_outlined':
        0xf4cc, // [outline] notification — access point, antenna, bars, broadcast, communication
    'wifi_password':
        0xf05a9, // device — access, access code, authentication, authorization, cellular
    'wifi_password_outlined':
        0xf069c, // [outline] device — access, access code, authentication, authorization, cellular
    'wifi_password_rounded':
        0xf03bb, // [round] device — access, access code, authentication, authorization, cellular
    'wifi_password_sharp':
        0xf04ae, // [sharp] device — access, access code, authentication, authorization, cellular
    'wifi_protected_setup':
        0xe6ec, // action — access, around, arrow, arrows, authenticate
    'wifi_protected_setup_outlined':
        0xf4cd, // [outline] action — access, around, arrow, arrows, authenticate
    'wifi_protected_setup_rounded':
        0xf02be, // [round] action — access, around, arrow, arrows, authenticate
    'wifi_protected_setup_sharp':
        0xeddf, // [sharp] action — access, around, arrow, arrows, authenticate
    'wifi_rounded':
        0xf02bf, // [round] notification — access point, antenna, bars, broadcast, communication
    'wifi_sharp':
        0xede0, // [sharp] notification — access point, antenna, bars, broadcast, communication
    'wifi_tethering':
        0xe6ed, // device — access point, cell, cellular, cellular data, connection
    'wifi_tethering_error':
        0xf05aa, // device — !, alert, attention, broken, caution
    'wifi_tethering_error_outlined':
        0xf069d, // [outline] device — !, alert, attention, broken, caution
    'wifi_tethering_error_rounded':
        0xf05aa, // [round] device — !, alert, attention, broken, caution
    'wifi_tethering_error_rounded_outlined': 0xf069d,
    'wifi_tethering_error_rounded_rounded': 0xf02c0,
    'wifi_tethering_error_rounded_sharp': 0xf04af,
    'wifi_tethering_error_sharp':
        0xf04af, // [sharp] device — !, alert, attention, broken, caution
    'wifi_tethering_off':
        0xe6ef, // device — cell, cellular, connection, connection disabled, connection off
    'wifi_tethering_off_outlined':
        0xf4cf, // [outline] device — cell, cellular, connection, connection disabled, connection off
    'wifi_tethering_off_rounded':
        0xf02c1, // [round] device — cell, cellular, connection, connection disabled, connection off
    'wifi_tethering_off_sharp':
        0xede2, // [sharp] device — cell, cellular, connection, connection disabled, connection off
    'wifi_tethering_outlined':
        0xf4d0, // [outline] device — access point, cell, cellular, cellular data, connection
    'wifi_tethering_rounded':
        0xf02c2, // [round] device — access point, cell, cellular, cellular data, connection
    'wifi_tethering_sharp':
        0xede3, // [sharp] device — access point, cell, cellular, cellular data, connection
    'wind_power':
        0xf07da, // home — abstract, air flow, alternative energy, blades, clean energy
    'wind_power_outlined':
        0xf072a, // [outline] home — abstract, air flow, alternative energy, blades, clean energy
    'wind_power_rounded':
        0xf0832, // [round] home — abstract, air flow, alternative energy, blades, clean energy
    'wind_power_sharp':
        0xf0782, // [sharp] home — abstract, air flow, alternative energy, blades, clean energy
    'window':
        0xe6f0, // search — aperture, application window, basic shape, browser window, close
    'window_outlined':
        0xf4d1, // [outline] search — aperture, application window, basic shape, browser window, close
    'window_rounded':
        0xf02c3, // [round] search — aperture, application window, basic shape, browser window, close
    'window_sharp':
        0xede4, // [sharp] search — aperture, application window, basic shape, browser window, close
    'wine_bar':
        0xe6f1, // maps — alcohol, alcohol consumption, bar, beverage, cafe
    'wine_bar_outlined':
        0xf4d2, // [outline] maps — alcohol, alcohol consumption, bar, beverage, cafe
    'wine_bar_rounded':
        0xf02c4, // [round] maps — alcohol, alcohol consumption, bar, beverage, cafe
    'wine_bar_sharp':
        0xede5, // [sharp] maps — alcohol, alcohol consumption, bar, beverage, cafe
    'woman': 0xf05ab, // social — account, avatar, character, circle, contact
    'woman_2': 0xf087c, // social — abstract, account, avatar, bust, female
    'woman_2_outlined':
        0xf08b8, // [outline] social — abstract, account, avatar, bust, female
    'woman_2_rounded':
        0xf089a, // [round] social — abstract, account, avatar, bust, female
    'woman_2_sharp':
        0xf0851, // [sharp] social — abstract, account, avatar, bust, female
    'woman_outlined':
        0xf069e, // [outline] social — account, avatar, character, circle, contact
    'woman_rounded':
        0xf03bd, // [round] social — account, avatar, character, circle, contact
    'woman_sharp':
        0xf04b0, // [sharp] social — account, avatar, character, circle, contact
    'woo_commerce': 0xf05ac,
    'woo_commerce_outlined': 0xf069f,
    'woo_commerce_rounded': 0xf03be,
    'woo_commerce_sharp': 0xf04b1,
    'wordpress': 0xf05ad,
    'wordpress_outlined': 0xf06a0,
    'wordpress_rounded': 0xf03bf,
    'wordpress_sharp': 0xf04b2,
    'work': 0xe6f2, // action — achievement, bag, baggage, briefcase, business
    'work_history':
        0xf07db, // action — activity log, archive, back, backwards, bag
    'work_history_outlined':
        0xf072b, // [outline] action — activity log, archive, back, backwards, bag
    'work_history_rounded':
        0xf0833, // [round] action — activity log, archive, back, backwards, bag
    'work_history_sharp':
        0xf0783, // [sharp] action — activity log, archive, back, backwards, bag
    'work_off': 0xe6f3, // action — bag, baggage, blocked, briefcase, business
    'work_off_outlined':
        0xf4d3, // [outline] action — bag, baggage, blocked, briefcase, business
    'work_off_rounded':
        0xf02c5, // [round] action — bag, baggage, blocked, briefcase, business
    'work_off_sharp':
        0xede6, // [sharp] action — bag, baggage, blocked, briefcase, business
    'work_outline':
        0xe6f4, // action — achievement, bag, baggage, briefcase, business
    'work_outline_outlined':
        0xf4d4, // [outline] action — achievement, bag, baggage, briefcase, business
    'work_outline_rounded':
        0xf02c6, // [round] action — achievement, bag, baggage, briefcase, business
    'work_outline_sharp':
        0xede7, // [sharp] action — achievement, bag, baggage, briefcase, business
    'work_outlined':
        0xf4d5, // [outline] action — achievement, bag, baggage, briefcase, business
    'work_rounded':
        0xf02c7, // [round] action — achievement, bag, baggage, briefcase, business
    'work_sharp':
        0xede8, // [sharp] action — achievement, bag, baggage, briefcase, business
    'workspace_premium':
        0xf05ae, // social — achievement, approval, authentic, authority, award
    'workspace_premium_outlined':
        0xf06a1, // [outline] social — achievement, approval, authentic, authority, award
    'workspace_premium_rounded':
        0xf03c0, // [round] social — achievement, approval, authentic, authority, award
    'workspace_premium_sharp':
        0xf04b3, // [sharp] social — achievement, approval, authentic, authority, award
    'workspaces':
        0xe6f5, // file — arrangement, circles, collaboration, computer, dashboard
    'workspaces_filled':
        0xe6f6, // file — circles, collaboration, dot, group, space
    'workspaces_outline':
        0xe6f7, // file — arrangement, circles, collaboration, computer, dashboard
    'workspaces_outlined':
        0xf4d6, // [outline] file — arrangement, circles, collaboration, computer, dashboard
    'workspaces_rounded':
        0xf02c8, // [round] file — arrangement, circles, collaboration, computer, dashboard
    'workspaces_sharp':
        0xede9, // [sharp] file — arrangement, circles, collaboration, computer, dashboard
    'wrap_text':
        0xe6f8, // editor — adjust, align, alignment, arrangement, arrow writing
    'wrap_text_outlined':
        0xf4d7, // [outline] editor — adjust, align, alignment, arrangement, arrow writing
    'wrap_text_rounded':
        0xf02c9, // [round] editor — adjust, align, alignment, arrangement, arrow writing
    'wrap_text_sharp':
        0xedea, // [sharp] editor — adjust, align, alignment, arrangement, arrow writing
    'wrong_location': 0xe6f9, // maps — address, alert, cancel, caution, clear
    'wrong_location_outlined':
        0xf4d8, // [outline] maps — address, alert, cancel, caution, clear
    'wrong_location_rounded':
        0xf02ca, // [round] maps — address, alert, cancel, caution, clear
    'wrong_location_sharp':
        0xedeb, // [sharp] maps — address, alert, cancel, caution, clear
    'wysiwyg':
        0xe6fa, // action — Rich text editor, basic editor, composer, composition, content creation
    'wysiwyg_outlined':
        0xf4d9, // [outline] action — Rich text editor, basic editor, composer, composition, content creation
    'wysiwyg_rounded':
        0xf02cb, // [round] action — Rich text editor, basic editor, composer, composition, content creation
    'wysiwyg_sharp':
        0xedec, // [sharp] action — Rich text editor, basic editor, composer, composition, content creation
    'yard': 0xe6fb, // search — area, backyard, building, compound, dwelling
    'yard_outlined':
        0xf4da, // [outline] search — area, backyard, building, compound, dwelling
    'yard_rounded':
        0xf02cc, // [round] search — area, backyard, building, compound, dwelling
    'yard_sharp':
        0xeded, // [sharp] search — area, backyard, building, compound, dwelling
    'youtube_searched_for':
        0xe6fc, // action — analysis, analytics, arrow, back, backwards
    'youtube_searched_for_outlined':
        0xf4db, // [outline] action — analysis, analytics, arrow, back, backwards
    'youtube_searched_for_rounded':
        0xf02cd, // [round] action — analysis, analytics, arrow, back, backwards
    'youtube_searched_for_sharp':
        0xedee, // [sharp] action — analysis, analytics, arrow, back, backwards
    'zoom_in': 0xe6fd, // action — add, big, bigger, circle, command
    'zoom_in_map': 0xf05af, // maps — add, arrow, arrows, cartography, center
    'zoom_in_map_outlined':
        0xf06a2, // [outline] maps — add, arrow, arrows, cartography, center
    'zoom_in_map_rounded':
        0xf03c1, // [round] maps — add, arrow, arrows, cartography, center
    'zoom_in_map_sharp':
        0xf04b4, // [sharp] maps — add, arrow, arrows, cartography, center
    'zoom_in_outlined':
        0xf4dc, // [outline] action — add, big, bigger, circle, command
    'zoom_in_rounded':
        0xf02ce, // [round] action — add, big, bigger, circle, command
    'zoom_in_sharp':
        0xedef, // [sharp] action — add, big, bigger, circle, command
    'zoom_out':
        0xe6fe, // action — adjust, decrease, decrease size, discover, document view
    'zoom_out_map': 0xe6ff, // maps — area, arrow, arrows, box, center
    'zoom_out_map_outlined':
        0xf4dd, // [outline] maps — area, arrow, arrows, box, center
    'zoom_out_map_rounded':
        0xf02cf, // [round] maps — area, arrow, arrows, box, center
    'zoom_out_map_sharp':
        0xedf0, // [sharp] maps — area, arrow, arrows, box, center
    'zoom_out_outlined':
        0xf4de, // [outline] action — adjust, decrease, decrease size, discover, document view
    'zoom_out_rounded':
        0xf02d0, // [round] action — adjust, decrease, decrease size, discover, document view
    'zoom_out_sharp':
        0xedf1, // [sharp] action — adjust, decrease, decrease size, discover, document view
  };
}
