//
//  AuthViewModel.swift
//  Clothing Mint
//
//  认证视图模型，管理登录/注册表单状态
//

import SwiftUI

/// 认证视图模型
@Observable
final class AuthViewModel {
    // MARK: - 表单字段

    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: - 状态

    var isLoading = false
    var errorMessage: String?
    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    // MARK: - 依赖

    private let authService = AuthService()

    // MARK: - 验证

    /// 验证登录表单
    var isLoginFormValid: Bool {
        Validators.isValidEmail(email) && Validators.isNotEmpty(password)
    }

    /// 验证注册表单
    var isSignUpFormValid: Bool {
        Validators.isValidEmail(email)
            && Validators.isNotEmpty(password)
            && password.count >= 6
            && password == confirmPassword
    }

    /// 邮箱验证错误提示
    var emailError: String? {
        if email.isEmpty { return nil }
        return Validators.isValidEmail(email) ? nil : "请输入有效的邮箱地址"
    }

    /// 密码验证错误提示
    var passwordError: String? {
        if password.isEmpty { return nil }
        return password.count >= 6 ? nil : "密码至少 6 位"
    }

    /// 确认密码错误提示
    var confirmPasswordError: String? {
        if confirmPassword.isEmpty { return nil }
        return password == confirmPassword ? nil : "两次密码不一致"
    }

    // MARK: - 操作

    /// 执行登录
    func login() async -> Bool {
        guard isLoginFormValid else {
            showError("请检查表单填写")
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(email: email, password: password)
            isLoading = false
            return true
        } catch {
            isLoading = false
            let message = mapAuthError(error)
            showError(message)
            return false
        }
    }

    /// 执行注册
    func signUp() async -> Bool {
        guard isSignUpFormValid else {
            showError("请检查表单填写")
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signUp(email: email, password: password)
            isLoading = false
            showSuccess("注册成功，请登录")
            return true
        } catch {
            isLoading = false
            let message = mapAuthError(error)
            showError(message)
            return false
        }
    }

    /// 清空表单
    func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }

    // MARK: - 私有方法

    private func showError(_ message: String) {
        errorMessage = message
        toastType = .error
        toastMessage = message
        showToast = true
        HapticFeedback.error()
    }

    private func showSuccess(_ message: String) {
        toastType = .success
        toastMessage = message
        showToast = true
        HapticFeedback.success()
    }

    /// 将 Auth 错误映射为用户友好的提示
    private func mapAuthError(_ error: Error) -> String {
        let desc = error.localizedDescription.lowercased()
        if desc.contains("invalid login credentials") || desc.contains("invalid_credentials") {
            return "邮箱或密码错误"
        } else if desc.contains("user already registered") || desc.contains("already been registered") {
            return "该邮箱已注册"
        } else if desc.contains("email not confirmed") {
            return "邮箱尚未验证"
        } else if desc.contains("network") || desc.contains("timeout") {
            return "网络连接失败，请重试"
        }
        AppLogger.error("认证错误: \(error)")
        return "操作失败，请重试"
    }
}
