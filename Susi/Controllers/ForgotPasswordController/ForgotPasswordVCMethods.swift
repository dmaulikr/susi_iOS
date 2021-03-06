//
//  ForgotPasswordVCMethods.swift
//  Susi
//
//  Created by Chashmeet Singh on 2017-06-04.
//  Copyright © 2017 FOSSAsia. All rights reserved.
//

import UIKit
import M13Checkbox
import SwiftValidators
import Material

extension ForgotPasswordViewController {

    // Dismiss View
    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    // Configures Email Field
    func prepareEmailField() {
        emailTextField.placeholderNormalColor = .white
        emailTextField.placeholderActiveColor = .white
        emailTextField.dividerNormalColor = .white
        emailTextField.dividerActiveColor = .red
        emailTextField.textColor = .white
        emailTextField.clearIconButton?.tintColor = .white
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }

    func prepareResetButton() {
        resetButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
    }

    func textFieldDidChange(textField: UITextField) {
        if textField == emailTextField, let emailID = emailTextField.text {
            if !emailID.isValidEmail() {
                emailTextField.dividerActiveColor = .red
            } else {
                emailTextField.dividerActiveColor = .green
            }
        }
    }

    @IBAction func toggleRadioButtons(_ sender: M13Checkbox) {
        if sender.checkState == .checked {
            addressTextField.tag = 1
            addressTextField.isUserInteractionEnabled = true
        } else {
            addressTextField.tag = 0
            addressTextField.isUserInteractionEnabled = false
            addressTextField.text = ""
        }
    }

    func prepareAddressField() {
        addressTextField.placeholderNormalColor = .white
        addressTextField.placeholderActiveColor = .white
        addressTextField.dividerNormalColor = .white
        addressTextField.dividerActiveColor = .white
        addressTextField.textColor = .white
    }

    // Call Reset Password API
    func resetPassword() {

        if let emailID = emailTextField.text, !emailID.isEmpty && emailID.isValidEmail() {

            let params = [
                Client.UserKeys.ForgotEmail: emailTextField.text?.lowercased()
            ]

            if personalServerButton.checkState == .unchecked {
                UserDefaults.standard.set(Client.APIURLs.SusiAPI, forKey: ControllerConstants.UserDefaultsKeys.ipAddress)
            } else {
                if let ipAddress = addressTextField.text, !ipAddress.isEmpty && Validator.isIP().apply(ipAddress) {
                    UserDefaults.standard.set(ipAddress, forKey: ControllerConstants.UserDefaultsKeys.ipAddress)
                } else {
                    view.makeToast("Invalid IP Address")
                    return
                }
            }

            self.toggleEditing()
            self.activityIndicator.startAnimating()

            Client.sharedInstance.resetPassword(params as [String : AnyObject]) { (_, message) in
                DispatchQueue.main.async {
                    self.toggleEditing()
                    self.activityIndicator.stopAnimating()

                    let errorDialog = UIAlertController(title: ControllerConstants.emailSent, message: message, preferredStyle: UIAlertControllerStyle.alert)
                    errorDialog.addAction(UIAlertAction(title: ControllerConstants.ok, style: .cancel, handler: { (_: UIAlertAction!) in
                        errorDialog.dismiss(animated: true, completion: nil)
                    }))
                    self.present(errorDialog, animated: true, completion: nil)

                    self.emailTextField.text = ""
                    self.emailTextField.endEditing(true)
                }
            }
        } else {
            self.view.makeToast("Invalid email address")
        }

    }

    // Toggle editing
    func toggleEditing() {
        emailTextField.isEnabled = !self.emailTextField.isEnabled
        resetButton.isEnabled = !self.resetButton.isEnabled
    }

    func setupTheme() {
        UIApplication.shared.statusBarStyle = .lightContent
        let activeTheme = UserDefaults.standard.string(forKey: ControllerConstants.UserDefaultsKeys.theme)
        if activeTheme == theme.light.rawValue {
            view.backgroundColor = UIColor.hexStringToUIColor(hex: "#4184F3")
            personalServerButton.secondaryCheckmarkTintColor = UIColor.hexStringToUIColor(hex: "#4184F3")
        } else if activeTheme == theme.dark.rawValue {
            view.backgroundColor = UIColor.defaultColor()
            personalServerButton.secondaryCheckmarkTintColor = UIColor.defaultColor()
        }

        if let navbar = navigationController?.navigationBar {
            if activeTheme == theme.light.rawValue {
                navbar.barTintColor = UIColor.hexStringToUIColor(hex: "#4184F3")
            } else if activeTheme == theme.dark.rawValue {
                navbar.barTintColor = UIColor.defaultColor()
            }
        }

    }

}
