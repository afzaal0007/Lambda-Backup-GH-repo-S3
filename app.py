import os
import subprocess
import tarfile
import boto3
import datetime
import shutil

def lambda_handler(event, context):
    # Configuration
    GITHUB_TOKEN = os.environ['GITHUB_TOKEN']
    S3_BUCKET = os.environ['S3_BUCKET']
    REPO_LIST_KEY = os.environ['REPO_LIST_KEY']
    GITHUB_ORG = os.environ.get('GITHUB_ORG', 'Digitify-UK')  # Make org configurable
    TMP_DIR = "/tmp"
    TIMESTAMP = datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')
    
    # Initialize clients
    s3 = boto3.client('s3')
    
    # Download repos.txt from S3
    local_repo_list_path = os.path.join(TMP_DIR, "repos.txt")
    try:
        s3.download_file(S3_BUCKET, REPO_LIST_KEY, local_repo_list_path)
    except Exception as e:
        print(f"❌ Failed to download repo list: {e}")
        return {
            'statusCode': 500,
            'body': f"Failed to download repo list: {e}"
        }

    # Read repo names (not full URLs)
    with open(local_repo_list_path, 'r') as f:
        repo_names = [line.strip() for line in f if line.strip()]

    success_count = 0
    failure_count = 0
    
    for repo_name in repo_names:
        # Clean repo name (remove .git if present)
        repo_name = repo_name.replace(".git", "")
        
        # Construct proper URLs
        repo_url = f"https://github.com/{GITHUB_ORG}/{repo_name}.git"
        repo_url_auth = f"https://{GITHUB_TOKEN}@github.com/{GITHUB_ORG}/{repo_name}.git"
        
        # Alternatively, use SSH (recommended for better security):
# repo_url_auth = f"git@github.com:{GITHUB_ORG}/{repo_name}.git"
        
        # Path setup
        repo_path = os.path.join(TMP_DIR, f"{repo_name}.git")
        archive_path = os.path.join(TMP_DIR, f"{repo_name}-{TIMESTAMP}.tar.gz")
        
        try:
            # Clone the repository
            print(f"⏳ Cloning {repo_name}...")
            subprocess.run(
                ["git", "clone", "--mirror", repo_url_auth, repo_path],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Create archive
            print(f"📦 Creating archive for {repo_name}...")
            with tarfile.open(archive_path, "w:gz") as tar:
                tar.add(repo_path, arcname=os.path.basename(repo_path))
            
            # Upload to S3
            s3_key = f"github-backups/{repo_name}/{repo_name}-{TIMESTAMP}.tar.gz"
            print(f"⬆️ Uploading {repo_name} backup to S3...")
            s3.upload_file(archive_path, S3_BUCKET, s3_key)
            
            print(f"✔️ Successfully backed up {repo_name}")
            success_count += 1
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Git operation failed for {repo_name}: {e.stderr}")
            failure_count += 1
        except Exception as e:
            print(f"❌ Failed to back up {repo_name}: {str(e)}")
            failure_count += 1
        finally:
            # Cleanup
            shutil.rmtree(repo_path, ignore_errors=True)
            if os.path.exists(archive_path):
                os.remove(archive_path)

    # Cleanup repo list file
    if os.path.exists(local_repo_list_path):
        os.remove(local_repo_list_path)

    return {
        'statusCode': 200,
        'body': {
            'message': 'Backup completed',
            'success_count': success_count,
            'failure_count': failure_count,
            'total_repositories': len(repo_names)
        }
    }