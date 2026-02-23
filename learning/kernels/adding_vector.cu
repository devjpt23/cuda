#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cuda_runtime.h>

#define N 100000000
#define BLOCK_SIZE 256

__global__ void addVectors(float* A, float* B, float* C, int vectorLength) {
    int uniqueIndex = blockIdx.x * blockDim.x + threadIdx.x;

    if (uniqueIndex < vectorLength) {
        C[uniqueIndex] = A[uniqueIndex] + B[uniqueIndex];
    }
}

int main() {

    // Vital steps for CUDA workflow since CPU and GPU have separate memory.
    // We want to run the compute on the powerful GPU.

    // 1. Allocate memory on the host (CPU)
    size_t size = N * sizeof(float);
    float *h_a = (float*)malloc(size);
    float *h_b = (float*)malloc(size);
    float *h_c = (float*)malloc(size);

    // 2. Initialize data on the CPU, in our case we fill the arrays
    for (int i = 0; i < N; i++) {
        h_a[i] = 1.0f;
        h_b[i] = 2.0f;
    }

    // 3. Allocate memory on the GPU
    float *d_a, *d_b, *d_c;
    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

    // 4. Copy content from CPU to GPU
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

    // 5. Launch kernel
    int blocks = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    addVectors<<<blocks, BLOCK_SIZE>>>(d_a, d_b, d_c, N);

    // 6. Copy results from GPU back to CPU
    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);
    printf("%f\n", h_c[0]); // should be 3.0

    // 7. Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}
