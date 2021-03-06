// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

extension ExposureDetectionViewController {
	func dynamicTableViewModel(for riskLevel: RiskLevel, riskDetectionFailed: Bool, isTracingEnabled: Bool) -> DynamicTableViewModel {
		if !isTracingEnabled {
			return offModel
		}

		if riskDetectionFailed {
			return failureModel
		}

		switch riskLevel {
		case .unknownInitial: return unknownRiskModel
		case .unknownOutdated: return outdatedRiskModel
		case .inactive: return offModel
		case .low: return lowRiskModel
		case .increased: return highRiskModel
		}
	}
}

// MARK: - Supported Header Types

private extension DynamicHeader {
	static func backgroundSpace(height: CGFloat) -> DynamicHeader {
		.space(height: height, color: .enaColor(for: .background))
	}

	static func riskTint(height _: CGFloat) -> DynamicHeader {
		.custom { viewController in
			let view = UIView()
			let heightConstraint = view.heightAnchor.constraint(equalToConstant: 16)
			heightConstraint.priority = .defaultHigh
			heightConstraint.isActive = true
			view.backgroundColor = (viewController as? ExposureDetectionViewController)?.state.riskBackgroundColor
			return view
		}
	}
}

// MARK: - Supported Cell Types

private extension DynamicCell {
	private enum ReusableCellIdentifer: String, TableViewCellReuseIdentifiers {
		case risk = "riskCell"
		case riskText = "riskTextCell"
		case riskRefresh = "riskRefreshCell"
		case riskLoading = "riskLoadingCell"
		case header = "headerCell"
		case guide = "guideCell"
		case longGuide = "longGuideCell"
		case link = "linkCell"
		case hotline = "hotlineCell"
	}

	private static let relativeDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.doesRelativeDateFormatting = true
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()

	private static func exposureDetectionCell(_ identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: GenericCellConfigurator<ExposureDetectionViewController>? = nil) -> DynamicCell {
		.custom(withIdentifier: identifier, action: action, accessoryAction: accessoryAction, configure: configure)
	}

	static func risk(hasSeparator: Bool = true, configure: @escaping GenericCellConfigurator<ExposureDetectionViewController>) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.risk) { viewController, cell, indexPath in
			let state = viewController.state
			cell.backgroundColor = state.riskBackgroundColor
			cell.tintColor = state.riskContrastTintColor
			cell.textLabel?.textColor = state.titleTextColor
			if let cell = cell as? ExposureDetectionRiskCell {
				cell.separatorView.isHidden = (indexPath.row == 0) || !hasSeparator
				cell.separatorView.backgroundColor = state.isTracingEnabled ? .enaColor(for: .hairlineContrast) : .enaColor(for: .hairline)
			}
			configure(viewController, cell, indexPath)
		}
	}

	static func riskLastRiskLevel(hasSeparator: Bool = true, text: String, image: UIImage?) -> DynamicCell {
		.risk(hasSeparator: hasSeparator) { viewController, cell, _ in
			let state = viewController.state
			cell.textLabel?.text = String(format: text, state.actualRiskText)
			cell.imageView?.image = image
		}
	}

	static func riskContacts(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			let state = viewController.state
			let risk = state.risk
			cell.textLabel?.text = String(format: text, risk?.details.numberOfExposures ?? 0)
			cell.imageView?.image = image
		}
	}

	static func riskLastExposure(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			let daysSinceLastExposure = viewController.state.risk?.details.daysSinceLastExposure ?? 0
			cell.textLabel?.text = .localizedStringWithFormat(text, daysSinceLastExposure)
			cell.imageView?.image = image
		}
	}

	static func riskStored(activeTracing: ActiveTracing, imageName: String) -> DynamicCell {
		.risk { viewController, cell, _ in
			let state = viewController.state
			var numberOfDaysStored = state.risk?.details.numberOfDaysWithActiveTracing ?? 0
			cell.textLabel?.text = activeTracing.localizedDuration
			if numberOfDaysStored < 0 { numberOfDaysStored = 0 }
			if numberOfDaysStored > 13 {
				cell.imageView?.image = UIImage(named: "Icons_TracingCircleFull - Dark")
			} else {
				cell.imageView?.image = UIImage(named: String(format: imageName, numberOfDaysStored))
			}
		}
	}

	static func riskRefreshed(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			var valueText: String
			if let date: Date = viewController.state.risk?.details.exposureDetectionDate {
				valueText = relativeDateTimeFormatter.string(from: date)
			} else {
				valueText = AppStrings.ExposureDetection.refreshedNever
			}

			cell.textLabel?.text = String(format: text, valueText)
			cell.imageView?.image = image
		}
	}

	static func riskText(text: String) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.riskText) { viewController, cell, _ in
			let state = viewController.state
			cell.backgroundColor = state.riskBackgroundColor
			cell.textLabel?.textColor = state.titleTextColor
			cell.textLabel?.text = text
		}
	}

	static func riskRefresh(text: String) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.riskRefresh) { viewController, cell, _ in
			let state = viewController.state
			cell.backgroundColor = state.riskBackgroundColor
			cell.textLabel?.text = AppStrings.ExposureDetection.refresh24h
		}
	}

	static func riskLoading(text: String) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.riskLoading) { viewController, cell, _ in
			let state = viewController.state
			cell.backgroundColor = state.riskBackgroundColor
			cell.textLabel?.text = text
		}
	}

	static func header(title: String, subtitle: String) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.header) { _, cell, _ in
			let cell = cell as? ExposureDetectionHeaderCell
			cell?.titleLabel?.text = title
			cell?.subtitleLabel?.text = subtitle
			cell?.titleLabel?.accessibilityTraits = .header
		}
	}

	static func guide(text: String, image: UIImage?) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.guide) { viewController, cell, _ in
			let state = viewController.state
			cell.tintColor = state.riskTintColor
			cell.textLabel?.text = text
			cell.imageView?.image = image
		}
	}

	static func guide(image: UIImage?, text: [String]) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.longGuide) { viewController, cell, _ in
			let state = viewController.state
			cell.tintColor = state.riskTintColor
			(cell as? ExposureDetectionLongGuideCell)?.configure(image: image, text: text)
		}
	}

	static func link(text: String, url: URL?) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.link, action: .open(url: url)) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func hotline(number: String) -> DynamicCell {
		.exposureDetectionCell(ReusableCellIdentifer.hotline) { _, cell, _ in
			(cell as? InsetTableViewCell)?.insetContentView.primaryAction = {
				if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			}
		}
	}
}

// MARK: - Exposure Detection Model

extension ExposureDetectionViewController {
	private func riskSection(isHidden: @escaping (DynamicTableViewController) -> Bool, cells: [DynamicCell]) -> DynamicSection {
		.section(
			header: .none,
			footer: .riskTint(height: 16),
			isHidden: isHidden,
			cells: cells
		)
	}

	private func riskDataSection(cells: [DynamicCell]) -> DynamicSection {
		riskSection(
			isHidden: { (($0 as? Self)?.state.activityState.isActive ?? false) },
			cells: cells
		)
	}

	private var riskRefreshSection: DynamicSection {
		riskSection(
			isHidden: { viewController in
				guard let state = (viewController as? ExposureDetectionViewController)?.state else { return true }
				if state.activityState.isActive { return true }
				return state.detectionMode != .automatic
			},
			cells: [
				.riskRefresh(text: AppStrings.ExposureDetection.refreshingIn)
			]
		)
	}

	private var riskLoadingSection: DynamicSection {
		var riskLoadingText = ""
		switch state.activityState {
		case .detecting:
			riskLoadingText = AppStrings.ExposureDetection.riskCardStatusDetectingBody
		case .downloading:
			riskLoadingText = AppStrings.ExposureDetection.riskCardStatusDownloadingBody
		default:
			break
		}

		return DynamicSection.section(
			header: .none,
			footer: .none,
			isHidden: { !(($0 as? Self)?.state.activityState.isActive ?? false) },
			cells: [
				.riskLoading(text: riskLoadingText)
			]
		)
	}

	private var standardGuideSection: DynamicSection {
		.section(
			header: .backgroundSpace(height: 16),
			cells: [
				.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
				.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "Icons - Hands")),
				.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "Icons - Mundschutz")),
				.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "Icons - Abstand")),
				.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "Icons - Niesen"))
			]
		)
	}

	/// - NOTE: This section should only be displayed when more than 0 exposures occured.
	private func lowRiskExposureSection(_ numberOfExposures: Int, accessibilityIdentifier: String?) -> DynamicSection {
		guard numberOfExposures > 0 else { return .section(cells: []) }

		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.lowRiskExposureTitle,
					subtitle: AppStrings.ExposureDetection.lowRiskExposureSubtitle
				),
				.body(
					text: AppStrings.ExposureDetection.lowRiskExposureBody,
					accessibilityIdentifier: accessibilityIdentifier
				)
			]
		)
	}

	private func activeTracingSection(accessibilityIdentifier: String?) -> DynamicSection {
		let p0 = NSLocalizedString(
			"ExposureDetection_ActiveTracingSection_Text_Paragraph0",
			comment: ""
		)

		let p1 = state.risk?.details.activeTracing.exposureDetectionActiveTracingSectionTextParagraph1 ?? ""

		let body = [p0, p1].joined(separator: "\n\n")

		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: NSLocalizedString(
						"ExposureDetection_ActiveTracingSection_Title",
						comment: ""
					),
					subtitle: NSLocalizedString(
						"ExposureDetection_ActiveTracingSection_Subtitle",
						comment: ""
					)
				),
				.body(
					text: body,
					accessibilityIdentifier: accessibilityIdentifier
				)
			]
		)
	}

	private func explanationSection(text: String, numberOfExposures: Int = -1, accessibilityIdentifier: String?) -> DynamicSection {
		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.explanationTitle,
					subtitle: AppStrings.ExposureDetection.explanationSubtitle
				),
				.body(text: text, accessibilityIdentifier: accessibilityIdentifier),
				infectionRiskExplanationFAQLink(numberOfExposures)
			].compactMap { $0 }
		)
	}

	/// - NOTE: This cell should only be displayed when more than 0 exposures occured.
	private func infectionRiskExplanationFAQLink(_ numberOfExposures: Int) -> DynamicCell? {
		guard numberOfExposures > 0 else { return nil }
		return .link(
			text: AppStrings.ExposureDetection.explanationFAQLinkText,
			url: URL(string: AppStrings.ExposureDetection.explanationFAQLink)
		)
	}

	private func highRiskExplanationSection(daysSinceLastExposureText: String, explanationText: String, isActive: Bool, accessibilityIdentifier: String?) -> DynamicSection {
		let daysSinceLastExposure = state.risk?.details.daysSinceLastExposure ?? 0
		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.explanationTitle,
					subtitle: AppStrings.ExposureDetection.explanationSubtitle
				),
				.body(
					text: [
						.localizedStringWithFormat(daysSinceLastExposureText, daysSinceLastExposure),
						explanationText
					].joined(),
					accessibilityIdentifier: accessibilityIdentifier)
			]
		)
	}

	private var offModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)),
				cells: [
					.riskText(text: AppStrings.ExposureDetection.offText),
					.riskLastRiskLevel(hasSeparator: false, text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "Icons_LetzteErmittlung-Light")),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextOff,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextOff)
		])
	}
	
	private var failureModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)),
				cells: [
					.riskText(text: AppStrings.ExposureDetection.riskCardFailedCalculationBody),
					.riskLastRiskLevel(hasSeparator: false, text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "Icons_LetzteErmittlung-Light")),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextOff,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextOff)
		])
	}

	private var outdatedRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			riskDataSection(
				cells: [
					.riskText(text: AppStrings.ExposureDetection.outdatedText),
					.riskLastRiskLevel(hasSeparator: false, text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "Icons_LetzteErmittlung-Light")),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextOutdated,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextOutdated
			)
		])
	}

	private var unknownRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			riskDataSection(cells: [
				.riskText(text: AppStrings.ExposureDetection.unknownText)
			]),
			riskRefreshSection,
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextUnknown,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextUnknown
			)
		])
	}

	private var lowRiskModel: DynamicTableViewModel {
		let activeTracing = state.risk?.details.activeTracing ?? .init(interval: 0)
		let numberOfExposures = state.risk?.details.numberOfExposures ?? 0

		return DynamicTableViewModel([
			riskDataSection(
				cells: [
				.riskContacts(text: AppStrings.Home.riskCardLowNumberContactsItemTitle, image: UIImage(named: "Icons_KeineRisikoBegegnung")),
				.riskStored(activeTracing: activeTracing, imageName: "Icons_TracingCircle-Dark_Step %u"),
				.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
			]),
			riskRefreshSection,
			riskLoadingSection,
			lowRiskExposureSection(
				numberOfExposures,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.lowRiskExposureSection
			),
			standardGuideSection,
			activeTracingSection(accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.activeTracingSection),
			explanationSection(
				text: numberOfExposures > 0 ?
					AppStrings.ExposureDetection.explanationTextLowWithEncounter :
					AppStrings.ExposureDetection.explanationTextLowNoEncounter,
				numberOfExposures: numberOfExposures,
				accessibilityIdentifier: numberOfExposures > 0 ? AccessibilityIdentifiers.ExposureDetection.explanationTextLowWithEncounter :
					AccessibilityIdentifiers.ExposureDetection.explanationTextLowNoEncounter
			)
		])
	}

	private var highRiskModel: DynamicTableViewModel {
		let activeTracing = state.risk?.details.activeTracing ?? .init(interval: 0)
		return DynamicTableViewModel([
			riskDataSection(cells: [
				.riskContacts(text: AppStrings.Home.riskCardHighNumberContactsItemTitle, image: UIImage(named: "Icons_RisikoBegegnung")),
				.riskLastExposure(text: AppStrings.ExposureDetection.lastExposure, image: UIImage(named: "Icons_Calendar")),
				.riskStored(activeTracing: activeTracing, imageName: "Icons_TracingCircle-Dark_Step %u"),
				.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
			]),
			riskRefreshSection,
			riskLoadingSection,
			.section(
				header: .backgroundSpace(height: 16),
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHome, image: UIImage(named: "Icons - Home")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "Icons - Abstand")),
					.guide(image: UIImage(named: "Icons - Hotline"), text: [
						AppStrings.ExposureDetection.guideHotline1,
						AppStrings.ExposureDetection.guideHotline2,
						AppStrings.ExposureDetection.guideHotline3,
						AppStrings.ExposureDetection.guideHotline4
					])
				]
			),
			activeTracingSection(
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.activeTracingSectionText
			),
			highRiskExplanationSection(
				daysSinceLastExposureText: AppStrings.ExposureDetection.explanationTextHighDaysSinceLastExposure,
				explanationText: AppStrings.ExposureDetection.explanationTextHigh,
				isActive: true,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextHigh
			)
		])
	}
}

extension ActiveTracing {
	var exposureDetectionActiveTracingSectionTextParagraph1: String {
		let format = NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph1", comment: "")
		return String(format: format, maximumNumberOfDays, inDays)
	}

	var exposureDetectionActiveTracingSectionTextParagraph0: String {
		return NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph0", comment: "")
	}
}
