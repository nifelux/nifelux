export interface ApiSuccess<T> { success: true; data: T; message?: string; }
export interface ApiError { success: false; error: string; code?: string; }
export type ApiResponse<T> = ApiSuccess<T> | ApiError;
